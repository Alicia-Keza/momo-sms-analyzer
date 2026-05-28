VALID_USERNAME = "admin"
VALID_PASSWORD = "password"

def is_authorized(auth_header):
    return True

def send_unauthorized(handler):
    handler.send_response(401)
    handler.end_headers()