import logging
from log import setup_logging
setup_logging()
logger = logging.getLogger(__name__)
import click
import json
import os
from glob import glob
from errinj.pm import inject_err_to_contract
import config
from llm.utils import trim_json_markers
from llm.adapters import OpenAILLMAdapter
from typing import List
from sol.utils import get_the_function, get_public_state_var_sigs
from utils import find_all_callees, slithir_funcs_to_text


@click.group()
def main():
    pass

@main.command()
@click.argument("ERC_FILE", type=click.Path(exists=True, dir_okay=False))
@click.argument("OUT", type=click.Path(exists=False, file_okay=False))
def inject(erc_file, out):
    if not os.path.exists(out):
        os.makedirs(out)
    inject_err_to_contract(erc_file, out)

@main.command()
@click.argument("OUT", type=click.Path(exists=False, file_okay=False))
def batch_inject(out):
    if not os.path.exists(out):
        os.makedirs(out)
    import tasks
    files = glob("dataset/err-inj/origin/*.sol")
    [tasks.process_file.s(file, out).delay() for file in files]

@main.command()
def info():
    """print dataset info
    """
    err_dist = {
        "20": { "call": 0, "emit": 0, "throw": 0, "interface": 0, "assign": 0, "return": 0},
        "721": { "call": 0, "emit": 0, "throw": 0, "interface": 0, "assign": 0, "return": 0},
        "1155": { "call": 0, "emit": 0, "throw": 0, "interface": 0, "assign": 0, "return": 0}
    }
    contracts_dist = {
        "20": 0,
        "721": 0,
        "1155": 0
    }
    
    files = glob("dataset/err-inj/injected/*.json")
    for file in files:
        with open(file, 'r') as f:
            meta = json.load(f)
        
        if meta['compile_error']:
            continue
        erc = meta['erc']
        
        for err_inj in meta['inj_errors']:
            inj_ty = err_inj['config'][0]
            err_dist[erc][inj_ty] += 1
        contracts_dist[erc] += 1

    print(err_dist)

    # Calculate totals for each row (ERC20, ERC721, ERC1155)
    row_totals = {erc: sum(actions.values()) for erc, actions in err_dist.items()}
    # Calculate totals for each column (call, emit, throw, interface, assign, return)
    column_totals = {}
    for actions in err_dist.values():
        for action, count in actions.items():
            column_totals[action] = column_totals.get(action, 0) + count

    print(row_totals)
    print(column_totals)
    print(contracts_dist)

def simple_audit(errs_json, llm_adapter):
    with open(errs_json, "r") as f:
        err_configs = json.load(f)
    for err_config in err_configs:
        contract_file = "./"+err_config['filepath']
        contract_name = err_config['contract']
        
        _, cu = compile(contract_file)
        with open(contract_file, "r") as f:
            file_lines = f.read().splitlines(True)

        if err_config["type"] == "interface":
            contracts = [c for c in cu.contracts if c.name == contract_name]
            if not contracts:
                logger.info(f"does not find contract '{contract_name}'")
                return None
            c = contracts[0]

            # use all signatures, rule, contract name, function name to construct audit prompt.
            fn_interfaces: List[str] = c.functions_signatures
            event_interfaces: List[str] = [f.full_name for f in c.events]
            statevar_interfaces: List[str] = list(get_public_state_var_sigs(c))
            interfaces_str = "\n".join(fn_interfaces + event_interfaces + statevar_interfaces)
            prompt = "The following code is the interface of contract " + contract_name + ". ERC rules require contracts to have "+err_config['rule']+". Does this interface contain this? Answer YES or NO. \n code:```\n"+interfaces_str+"\n```"

            response = llm_adapter.ask([{"content": prompt, "role":"user"}])
            if response:
                err_config["llm_can_detect"] = "NO" in response[0]
        else:
            function_name = err_config['function']
            fn = get_the_function(cu, contract_name, fname=function_name)
            if not fn:
                continue

            # use func_text, rule, contract name, function name to construct audit prompt.
            to_explore = set()
            to_explore.add(fn)
            explored = find_all_callees(to_explore)
            func_text = slithir_funcs_to_text(explored, file_lines, True, False, True, True)
            prompt = "The following code is the implementation of function "+function_name+" in contract " + contract_name + ". ERC rules require \""+err_config['rule']+"\". Does this interface violate this rule? Answer YES or NO. \n code:```\n"+func_text+"\n```"
            
            response = llm_adapter.ask([{"content": prompt, "role":"user"}])
            if response:
                err_config["llm_can_detect"] = "YES" in response[0]

    with open(errs_json, "w") as f:
        json.dump(err_configs, f, indent=4)

@main.command()
@click.argument("folder", type=click.Path(exists=True))
def simple_audit_batch(folder):
    llm_adapter = OpenAILLMAdapter(config.OPENAI_KEY, "gpt-4-turbo")
    for filename in os.listdir(folder):
        if ".json" not in filename:
            continue
        simple_audit("./"+folder+filename, llm_adapter)

@main.command()
@click.argument("folder", type=click.Path(exists=True))
@click.option("--type") # example: ERC20
@click.option("--out")
def full_audit_batch(folder, type, out):
    llm_adapter = OpenAILLMAdapter(config.OPENAI_KEY, "gpt-4-turbo")
    for filename in os.listdir(folder):
        if ".sol" not in filename:
            continue
        contract_file = "./"+folder+filename
        full_audit(llm_adapter, contract_file, type, out)

def full_audit(llm_adapter,filepath, erctype, out):
    c_file = open(filepath, "r")
    code = c_file.read()
    c_file.close()
    erc_file = open("./erc/"+erctype)
    erc_rules = erc_file.read()
    erc_file.close()    
    prompt = "The following code is an implementation of "+erctype+". The "+erctype+" rules is attached below the code. Does this implementation violate "+erctype+" rules? Return a JSON array containing JSON objects with 'rule' and 'function' as keys, indicating the specific rule content that is violated and the function where the violation resides.\ncode:```\n"+code+"\n```\n"+erctype+":\n"+erc_rules
    response = llm_adapter.ask([{"content": prompt, "role":"user"}])[0]
    detect_res = json.loads(trim_json_markers(response))
    res_file = open(out+filepath.split("/")[-1].split(".")[0]+".json","w")
    json.dump(detect_res, res_file, indent=4)
    res_file.close()

@main.command()
@click.argument("folder", type=click.Path(exists=True))
@click.option("--err-dir")
@click.option("--out")
def rule_audit_batch(folder, err_dir, out):
    llm_adapter = OpenAILLMAdapter(config.OPENAI_KEY, "gpt-4-turbo")
    for filename in os.listdir(folder):
        if ".sol" not in filename:
            continue

        errs_json = "./"+err_dir+filename.split(".")[0]+".json"
        if not os.path.exists(errs_json):
            continue
        contract_file = "./"+folder+filename
        c_file = open(contract_file, "r")
        code = c_file.read()
        c_file.close()

        with open(errs_json, "r") as f:
            err_configs = json.load(f)
        for err_config in err_configs:
            func_name = err_config.get("function")
            err_config["llm_can_detect"] = audit(code, err_config['rule'], err_config['contract'], func_name, llm_adapter)

        with open(out+filename.split(".")[0]+".json", "w") as f:
            json.dump(err_configs, f, indent=4)

def audit(code: str, rule:str, contract:str, function:str, llm_adapter: OpenAILLMAdapter) -> bool:
    prompt = f"""Whether the following smart contract {contract} violate ERC rule \"{rule}\" {("for function "+function) if function else ""}? Answer YES or NO.
            Code:\"\"\"
            {code}
            \"\"\"
            """
    res = llm_adapter.ask([{"content": prompt, "role":"user"}], temperature=0, n=1)[0]
    return res.find("YES") != -1
