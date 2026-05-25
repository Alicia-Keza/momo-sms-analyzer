from __future__ import __annotations__


import time
from pathlib import Path

#make the script runnable

import sys
sys.path.insert(0,str(Path(__file__).resolve().parent.parent))

from dsa.parse.xml import load_transactions

## search methods

""" searching through the list tell we find the matching id """
def linear_search(transactions: list[dict], target_id: int) -> dict | None:
    for tx in transactions:
        if tx["id"] == target_id:
            return tx
    return None

""""creating alookup table (transaction id) in a pass"""
def build_index(transactions: list[dict]) -> dict[int, dict]:
    return {tx["id"]: tx for tx in transactions}

 
"""hash table lookup"""
def dict_lookup(index: dict[int, dict], target_id: int) -> dict | None:
    return index.get(target_id)




