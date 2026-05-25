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
    
    # routes

    def do_GET(self):
        if not self._check_auth():
            return
        
        path = urlparse(self.path).path

        if path in ("/transactions", "/transactions/"):
            self._send_json(200, crud.list_all())
            return
        
        tx_id = self._parse_id_from_path()
        if tx_id is not None:
            record = crud.get_by_id(tx_id)
            if record is None:
                self._send_json(404, {"error": "Transaction not found"})
            else:
                self._send_json(200, record)
            return
        
        self._send_json(404, {"error": "Route not found"})


    def do_POST(self):
        if not self._check_auth():
            return
        
        if urlparse(self.path).path not in ("/transactions", "/transactions/"):
            self._send_json(404, {"error": "Route not found"})
            return
        
        body = self._read_json_body()
        if body is None:
            self._send_json(400, {"error": "Invalid JSON body"})
            return
        
        record = crud.create(body)
        self._send_json(201, record)


    def do_PUT(self):
        if not self._check_auth():
            return
        
        tx_id = self._parse_id_from_path()
        if tx_id is None:
            self._send_json(404, {"error": "Route not found"})
            return
        
        body = self._read_json_body()
        if body is None:
            self._send_json(400, {"error": "Invalid JSON body"})
            return
        
        updated = crud.update(tx_id, body)
        if updated is None:
            self._send_json(404, {"error": "Transaction not found"})
        else:
            self._send_json(200, updated)

    def do_DELETE(self):
        if not self._check_auth():
            return

        tx_id = self._parse_id_from_path()
        if tx_id is None:
            self._send_json(404, {"error": "Route not found"})
            return

        deleted_id = crud.delete(tx_id)
        if deleted_id is None:
            self._send_json(404, {"error": "Transaction not found"})
        else:
            self._send_json(200, {"deleted": deleted_id})


def run_server(host: str = "", port: int = 8000) -> None:
    server = HTTPServer((host, port), MoMoHandler)
    from api.auth import VALID_USERNAME
    print(f"Starting server on {host or 'localhost'}:{port} (use username '{VALID_USERNAME}')...")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down server...")
        server.server_close()

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8000"))
    run_server(port=port)