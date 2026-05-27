import os
import sys

here = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(here)
sys.path.insert(0, project_root)

from dsa.parse_xml import load_transactions, save_as_json


# file paths
XML_PATH = os.path.join(project_root, "modified_sms_v2.xml")
JSON_PATH = os.path.join(project_root, "transactions.json")

# load all transactions once when this file is imported
TRANSACTIONS = load_transactions(XML_PATH)

# find the next id to use for new transactions
NEXT_ID = 1
for t in TRANSACTIONS:
    if t["id"] >= NEXT_ID:
        NEXT_ID = t["id"] + 1