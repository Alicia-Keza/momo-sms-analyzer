from __future__ import annotations

import json
import re
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

# This is for matching '5000rwf', '5,000 RWF', '5,000.00 RWF' etc
_AMOUNT_RE = re.compile(r"([\d][\d,]*(?:\.\d+)?)\s*RWF", re.IGNORECASE)

_TXID_RE = re.compile(
    r"(?:Financial\s+Transaction\s+Id|TxId)\s*[:\s]\s*(\d+)",
    re.IGNORECASE,
) 

_RECEIVED_FROM_RE = re.compile(
    r"received\s+[\d,\.]+\s*RWF\s+from\s+([A-Z][\w'\-\.]*(?:\s+[A-Z][\w'\-\.]*)*)",
    re.IGNORECASE,
)
_PAYMENT_TO_RE = re.compile()
_PAYMENT_TO_RE = re.compile(
    r"payment\s+of\s+[\d,\.]+\s*RWF\s+to\s+([A-Z][\w'\-\.]*(?:\s+[A-Z][\w'\-\.]*)*)",
    re.IGNORECASE,
)
_TRANSFER_TO_RE = re.compile(
    r"transferred\s+to\s+([A-Z][\w'\-\.]*(?:\s+[A-Z][\w'\-\.]*)*)",
    re.IGNORECASE,

)
_WITHDRAWN_BY_RE = re.compile(
    r"You\s+([A-Z][\w'\-\.]*(?:\s+[A-Z][\w'\-\.]*)*)\s+\(",
    re.IGNORECASE,
)

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

def _extract_amount(body: str) -> float:
    """Pull the fiirst  RWF amount out of the body and return it as a float """
    m = _AMOUNT_RE.search(body)
    if not m:
        return 0.0
    return float(m.group(1).replace(",", ""))

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
        return ("You", m.group(1).strip() if m else "") 
    if tx_type == "deposit":
        return ("Bank", "You")
    return ("", "")

def _extract_external_tx_id(body: str) -> str:
    m = _TXID_RE.search(body)
    return m.group(1) if m else ""

def _epoch_ms_to_iso(epoch_ms: int) -> str:
    try: 
        seconds = int(epoch_ms) / 1000.0
        return (
            datetime.fromtimestamp(seconds, tz=timezone.utc)
            .strftime("%Y-%m-%dT%H:%M:%SZ")
        )
    except (TypeError, ValueError):
        return ""

#public api

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