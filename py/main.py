import logging
from log import setup_logging
setup_logging()
logger = logging.getLogger(__name__)
import click
import json
import os
from glob import glob
from errinj.pm import inject_err_to_contract


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
    import celery
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
