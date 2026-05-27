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


# Benchmark
"""run both methods many times against the worst_case target and return  a dict of measured numbers."""
def benchmark(transactions: list[dict], iterations: int = 5000)  -> dict:
    if len(transactions) < 20:
        raise ValueError(
            f"Need at least 20 records to benchmark, got {len(transactions)}"

        )
    index = build_index(transactions)
    #worst case for linear search =last item in the list
    target_id = transactions[-1]["id"]

 # linear search timing
    t0 = time.perf_counter()
    for _ in range(iterations):
        linear_search(transactions,target_id)
    linear_total = time.perf_counter() - t0

 # dictionary lookup timing
    t0 = time.perf_counter() 
    for _ in range(iterations): 
        dict_lookup(index,target_id)
    dict_total = time.perf_counter() - t0

    return{
        "records":len(transactions),
        "iterations":iterations,
        "target_id":target_id,
        "linear_total_s":linear_total,
        "linear_avg_us":(linear_total/iterations)* 1_000_000,
        "dict_total_s":dict_total,
        "dict_avg_us":(dict_total/iterations) * 1_000_000,
        "speedup": linear_total / dict_total if dict_total > 0 else float("inf")
    }
def print_report(result: dict) -> None:
    print("=" * 60)
    print("DSA BENCHMARK - linear search vs dictionary lookup")
    print("=" * 60)
    print(f"Records in list: {result['records']:>12,}")
    print(f"Iterations per test : {result['iterations']:>12,}")
    print(f"Target id (worst)   : {result['target_id']:>12}")
    print()
    print(f"Linear search       : {result['linear_total_s']:>10.4f} s total"
          f"   ({result['linear_avg_us']:>8.2f} us per lookup)")
    print(f"Dictionary lookup   : {result['dict_total_s']:>10.4f} s total"
          f"   ({result['dict_avg_us']:>8.2f} us per lookup)")
    print()
    print(f"Speed-up factor     : {result['speedup']:>10.1f} x")
    print("=" * 60)
    print()
    print("REFLECTION")
    print("-" * 60)
    print(
    "Linear search is O(n) because it checks transactions one by one. "
    "Dictionary lookup is faster at O(1) average time because Python "
    "dictionaries use hash tables. Another useful data structure is "
    "a binary search tree, which keeps data ordered and allows "
    "searching in O(log n) time."
    )







