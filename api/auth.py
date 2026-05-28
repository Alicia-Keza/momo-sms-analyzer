"""
api/auth.py - Basic Auth for the MoMo REST API.
Owner: Person C

Loads credentials from environment variables (never hard-coded).
Exposes two functions for server.py to call:
    is_authorized(auth_header) -> True/False
    send_unauthorized(handler) -> writes a 401 response
"""

import base64
import json
import os
import sys


# Read credentials from environment variables.
# If they are missing, refuse to start - this avoids hard-coding secrets.
VALID_USERNAME = os.environ.get("API_USERNAME")
VALID_PASSWORD = os.environ.get("API_PASSWORD")

if not VALID_USERNAME or not VALID_PASSWORD:
    sys.stderr.write(
        "ERROR: API_USERNAME and API_PASSWORD environment variables must be set.\n"
        "Copy .env.example to .env, fill in values, then:\n"
        "  export API_USERNAME=admin\n"
        "  export API_PASSWORD=password123\n"
    )
    sys.exit(1)


def is_authorized(auth_header):
    # No header, or wrong scheme -> reject.
    if not auth_header or not auth_header.startswith("Basic "):
        return False

    # Decode "Basic <base64>" -> "username:password".
    try:
        encoded = auth_header.split(" ", 1)[1].strip()
        decoded = base64.b64decode(encoded).decode("utf-8")
        username, password = decoded.split(":", 1)
    except (ValueError, UnicodeDecodeError, base64.binascii.Error):
        return False

    return username == VALID_USERNAME and password == VALID_PASSWORD


def send_unauthorized(handler):
    # Write a 401 JSON response onto the given HTTP handler.
    payload = json.dumps({"error": "Unauthorized"}).encode("utf-8")
    handler.send_response(401)
    handler.send_header("WWW-Authenticate", 'Basic realm="MoMo API"')
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Content-Length", str(len(payload)))
    handler.end_headers()
    handler.wfile.write(payload)