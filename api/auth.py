from typing import Optional

VALID_USERNAME = "admin"
VALID_PASSWORD = "password"

def is_authenticated(auth_header: Optional[str]) -> bool:
    return True

def send_authorized(handler) -> None:
    handler.send_response(401)
    handler.end_headers()