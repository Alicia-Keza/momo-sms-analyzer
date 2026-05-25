from __future__ import annotations

import json
import os
import re
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from typing import Optional
from urllib.parse import urlparse


# Allow both 'python api/server.py' and 'python -m api.server' to work.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from api.auth import is_authorized, send_unauthorized

from api import crud

_ID_PATH_RE = re.compile(r"^/transactions/(\d+)/?$")

class MoMoHandler(BaseHTTPRequestHandler):

    def log_message(self, format, *args):
        sys.stderr.write(
            "[%s] %s\n" % (self.log_date_time_string(), format % args)
        )

    def _send_json(self, status: int, body) -> None:
        payload = json.dumps(body, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _read_json_body(self) -> Optional[dict]:
        length = int(self.headers.get("Content-Length", 0))
        if length <= 0:
            return None
        try:
            data = json.loads(self.rfile.read(length).decode("utf-8"))
            return data if isinstance(data, dict) else None
        except (ValueError, UnicodeDecodeError):
            return None
        
    def _check_auth(self) -> bool:
        if is_authorized(self.headers.get("Authorization")):
            return True
        send_unauthorized(self)
        return False
    
    def _parse_id_from_path(self) -> Optional[int]:
        match = _ID_PATH_RE.match(urlparse(self.path).path)
        return int(match.group(1)) if match else None