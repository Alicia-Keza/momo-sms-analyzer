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

VALID_CREDS = base64.b64encode(f"{USERNAME}:{PASSWORD}".encode()).decode()
WRONG_CREDS = base64.b64encode(b"hacker:wrongpassword").decode()    

def request(method, path, body=None, creds=VALID_CREDS, send_auth=True):
    """Send an HTTP request and return (status_code, parsed_json)."""
    data = json.dumps(body).encode("utf-8") if body is not None else None 
    req = urllib.request.Request(BASE_URL + path, data=data, method=method)
    if send_auth and creds is not None:
        req.add_header("Authorization", f"Basic {creds}")
    if body is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read().decode("utf-8")
            return resp.status, (json.loads(raw) if raw else None)
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8") if e.fp else ""
        return e.code, (json.loads(raw) if raw else None)
            
_PASSED = 0
_FAILED = 0

def check(description, condition):
    global _PASSED, _FAILED
    mark = "PASS" if condition else "FAIL"
    print(f"[{mark}] {description}")
    if condition:
        _PASSED += 1
    else:
        _FAILED += 1


def test_list_with_auth():
    print("\nTEST 1: GET /transactions with valid auth")
    status, body= request("GET", "/transactions")
    check("status code is 200", status == 200)
    check("response is a list", isinstance(body, list))
    check("list has atleast 1 record", isinstance(body, list) and len(body) > 0)    

def test_list_without_auth():
    print("\nTEST 2: GET /transactions without header")
    status, body = request("GET", "/transactions", send_auth=False)
    check("status code is 401", status == 401)
    check(
        "error message is 'Unauthorized'",
        isinstance(body, dict) and body.get("error") == "Unauthorized",     

    )
def test_list_with_wrong_creds():
    print("\nTEST 3: GET/transactions with wrong credentials")
    status, body = request("GET", "/transctions", creds=WRONG_CREDS)
    check("status code is 401", status == 401)    

def test_get_one():
    print("\nTEST 4: GET /transactions/1")
    status, body =request ("GET", "/transactions/1")
    check("status code is 200", status == 200)
    check("response has an id field", isinstance(body, dict) and "id" in body)
    check("returned id == 1", isinstance(body, dict) and body.get("id") == 1)

def test_get_missing():
    print("\nTEST 5: GET /transactions/99999999 (does not exist) ")
    status, body = request("GET", "/transactions/99999999")
    check("status code is 404", status == 404)
        
def test_create_update_delete():
    print("\nTEST 6: POST -> PUT -> DELETE round trip")
    new_txn ={
        "transaction_type": "test_send",
        "amount": 123.56,
        "sender": "Test Sender",
        "receiver": "Test Receiver",
        "timestamp": "2026-05-22t12:00:00Z",
        "external_tx_id": "TEST123",
        "raw_body": "automate test transaction",
    }
    
    # POST
    status, created =request("POST", "/transactions", body=new_txn)
    check("POST status code is 201", status == 201)
    check("created object has an id", isinstance(created, dict) and "id" in created)
    new_id = created["id" ] if isinstance(created, dict) else None

    # PUT
    if new_id is not None:
        status, updated = request(
            "PUT", f"/transactions/{new_id}", body={"amount": 9999.99}
        )
        check("PUT status code is 200", status == 200)
        check(
            "amount was updates to 9999.99",
            isinstance(updated, dict) and updated.get("amount") == 9999.99,
        )
    # DELETE
    if new_id is not None:
        status, deleted = request("DELETE", f"/transactions/{new_id}")
        check("DELETE status code is 200", status == 200)
        check(
            "deleted object matches",
            isinstance(deleted, dict) and deleted.get("deleted") == new_id,
        )   

        status, _ = request("GET", f"/transactions/{new_id}")
        check("GET after delete returns 404", status == 404) 
