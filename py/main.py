from collections import defaultdict
import logging
from log import setup_logging
setup_logging()
logger = logging.getLogger(__name__)
import click
import json
import os
@click.group()
def main():
    pass

@main.command()
def merge():
    final = defaultdict(list)
    with open('10k_erc_ct.json', "r") as f:
        meta = json.load(f)
        for erc, items in meta.items():
            for item in items:
                item["file"] = item["file"].replace("local/10k", "dataset/err-inj/origin")
                if not os.path.exists(item['file']):
                    print(f"cannot find {item['file']}")
                item["from"] = "etherscan"
            final[erc].extend(items)

        
    with open('plyscan_erc_ct.json', "r") as f:
        meta = json.load(f)
        for erc, items in meta.items():
            for item in items:
                item["file"] = item["file"].replace("local/polyscan", "dataset/err-inj/origin")
                if not os.path.exists(item['file']):
                    print(f"cannot find {item['file']}")
                item["from"] = "polyscan"
            final[erc].extend(items)
    
    with open('final.json', "w") as f:
        json.dump(final, f, indent=4)