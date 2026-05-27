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

def find_index_by_id(tx_id):
    # loop through the list and return the position where id matches
    for i in range(len(TRANSACTIONS)):
        if TRANSACTIONS[i]["id"] == tx_id:
            return i
    return None

def save_to_disk():
    # write the current list to disk after every change
    save_as_json(TRANSACTIONS, JSON_PATH)

def list_all():
    return TRANSACTIONS

def get_by_id(tx_id):
    i = find_index_by_id(tx_id)
    if i is None:
        return None
    return TRANSACTIONS[i]

def create(payload):
    global NEXT_ID
    payload["id"] = NEXT_ID
    NEXT_ID = NEXT_ID + 1
    TRANSACTIONS.append(payload)
    save_to_disk()
    return payload

def update(tx_id, body):
    i = find_index_by_id(tx_id)
    if i is None:
        return None
    body["id"] = tx_id  # do not let the id change
    TRANSACTIONS[i].update(body)
    save_to_disk()
    return TRANSACTIONS[i]

def delete(tx_id):
    i = find_index_by_id(tx_id)
    if i is None:
        return None
    TRANSACTIONS.pop(i)
    save_to_disk()
    return tx_id

# run the file alone to test the functions
if __name__ == "__main__":
    print("Loaded ", len(list_all()), " transactions")

    first = get_by_id(1)
    print("First transaction: ", first["id"], first["transaction_type"], first["amount"])

    test = create({
        "transaction_type": "test",
        "amount": 3500,
        "sender": "A",
        "receiver": "B"
    })
    print("Created transaction test tx with id: ", test["id"])

    updated = update(test["id"], {"amount": 5000})
    print("Updated transaction test tx with new amount: ", updated["amount"])

    deleted_id = delete(test["id"])
    print("Deleted transaction with id: ", deleted_id)

    print("All transactions count: ", len(list_all()))