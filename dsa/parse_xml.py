from __future__ import annotations

import json
import re
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path

# This is for matching transaction amounts like:
# "5000 RWF", "5,000 RWF", "5,000.00 RWF" 
_AMOUNT_RE = re.compile(r"([\d][\d,]*(?:\.\d+)?)\s*RWF", re.IGNORECASE)

# This regex extracts transaction ids like:
# "Financial Transaction Id: 12345"
# or "TxId: 12345"
_TXID_RE = re.compile(
    r"(?:Financial\s+Transaction\s+Id|TxId)\s*[:\s]\s*(\d+)",
    re.IGNORECASE,
) 

# Finds the sender name in messages saying money was received
_RECEIVED_FROM_RE = re.compile(
    r"received\s+[\d,\.]+\s*RWF\s+from\s+([A-Z][\w'\-\.]*(?:\s+[A-Z][\w'\-\.]*)*)",
    re.IGNORECASE,
)

# Finding  the receiver name in  payment messages
_PAYMENT_TO_RE = re.compile(
    r"payment\s+of\s+[\d,\.]+\s*RWF\s+to\s+([A-Z][\w'\-\.]*(?:\s+[A-Z][\w'\-\.]*)*)",
    re.IGNORECASE,
)

# This  finding the receiver name in  transfer messages
_TRANSFER_TO_RE = re.compile(
    r"transferred\s+to\s+([A-Z][\w'\-\.]*(?:\s+[A-Z][\w'\-\.]*)*)",
    re.IGNORECASE,

)

# for finding  the person involved in withdrawal messages
_WITHDRAWN_BY_RE = re.compile(
    r"You\s+([A-Z][\w'\-\.]*(?:\s+[A-Z][\w'\-\.]*)*)\s+\(",
    re.IGNORECASE,
)

# Detecting  transaction type from SMS  message content
def _classify(body: str) -> str:
    text = body.lower()
    if "received" in text and "from" in text:
        return "receive_money"  
    if "transferred to" in text:
        return "send_money"
    if "bank deposit" in text or "deposit" in text and "added" in text:
        return "deposit"
    if "withdrawn" in text:
        return "withdrawal"
    if "airtime" in text:
        return "airtime"
    if "bank transfer" in text:
        return "bank_transfer"
    if "payment" in text:
        return "payment"
    return "other"

# This onee   extractsthe first amount found in the SMS body
def _extract_amount(body: str) -> float:
    """Pull the fiirst  RWF amount out of the body and return it as a float """
    m = _AMOUNT_RE.search(body)
    if not m:
        return 0.0
    return float(m.group(1).replace(",", ""))

# This gets sender and receiver depending on transaction type
def _extract_party(body: str, tx_type: str) -> tuple[str, str]:
    '''Return (sender, receiver) extracted from the body  .'''

    if tx_type == "receive_money":
        m = _RECEIVED_FROM_RE.search(body)
        return (m.group(1).strip() if m else "", "You") 
    if tx_type == "send_money":
        m = _TRANSFER_TO_RE.search(body)
        return ("You", m.group(1).strip() if m else "") 
    if tx_type == "payment":
        m = _PAYMENT_TO_RE.search(body)
        return ("You", m.group(1).strip() if m else "") 
    if tx_type == "withdrawal":
        m = _WITHDRAWN_BY_RE.search(body)
        return (m.group(1).strip() if m else "You", "Agent") 
    if tx_type == "deposit":
        return ("Bank", "You")
    return ("", "")


def _extract_external_tx_id(body: str) -> str: 
    m = _TXID_RE.search(body)
    return m.group(1) if m else ""

# Converts epoch milliseconds into readable UTC time
def _epoch_ms_to_iso(epoch_ms: str) -> str:
    try: 
        seconds = int(epoch_ms) / 1000.0
        return (
            datetime.fromtimestamp(seconds, tz=timezone.utc)
            .strftime("%Y-%m-%dT%H:%M:%SZ")
        )
    except (TypeError, ValueError):
        return ""

#public api
# Converting one SMS XML element into  a transaction dictionary
def _extract_transaction(sms_element, tx_id: int) -> dict:
    body = sms_element.get("body", "")
    tx_type = _classify(body)
    sender, receiver = _extract_party(body, tx_type)
    return {
        "id": tx_id,
        "transaction_type": tx_type,
        "amount": _extract_amount(body),
        "sender": sender,
        "receiver": receiver,
        "timestamp": _epoch_ms_to_iso(sms_element.get("date", "0")),
        "external_tx_id": _extract_external_tx_id(body),
        "raw_body": body,
    }

# Loads all SMS transactions  from the XML file
def load_transactions(
    xml_path: str | Path = "modified_sms_v2.xml",
) -> list[dict]:
    """Parse the XML and return a list of transaction dicts.

    The list is ordered by appearance in the file. IDs are 1-based.
    """
    tree = ET.parse(xml_path)
    root = tree.getroot()
    transactions: list[dict] = []
    for idx, sms in enumerate(root.findall(".//sms"), start=1):
        transactions.append(_extract_transaction(sms, idx))
    return transactions

# To save parsed transactions  into a JSON file
def save_as_json(
    transactions: list[dict],
    json_path: str | Path = "transactions.json",
) -> None:
    """Write the transactions list to a JSON file (pretty-printed)."""
    Path(json_path).write_text(json.dumps(transactions, indent=2))


if __name__ == "__main__":
    here = Path(__file__).resolve().parent.parent
    xml_file = here / "modified_sms_v2.xml"
    out_file = here / "transactions.json"

    txs = load_transactions(xml_file)
    save_as_json(txs, out_file)

    print(f"Parsed {len(txs)} transactions from {xml_file.name}")
    print(f"Saved JSON snapshot to {out_file.name}")

    # Checkin  of the first 3 records
    print("\nFirst 3 records:")
    for t in txs[:3]:
        print(
            f"  #{t['id']:>4}  {t['transaction_type']:<14} "
            f"{t['amount']:>10,.2f} RWF  "
            f"{t['sender'] or '-'} -> {t['receiver'] or '-'}"
        )