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