"""
tests/test_api.py
=================
End-to-end smoke test for the MoMo REST API.

Run *while the server is running*::

    # Terminal 1
    export API_USERNAME=admin
    export API_PASSWORD=password123
    python -m api.server

    # Terminal 2 (same env vars exported)
    python tests/test_api.py

Exits 0 on success, non-zero on first failure.
"""

from __future__ import annotations

import base64
import json
import os       
import sys
import urllib.error
import urllib.request

BASE_URL = os.environ.get("API_BASE_URL", "http://localhost:8000")
USERNAME = os.environ.get("API_USERNAME", "admin")
PASSWORD = os.environ.get("API_PASSWORD", "password123")

