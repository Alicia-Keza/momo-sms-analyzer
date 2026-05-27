VALID_USERNAME = "admin"
VALID_PASSWORD = "password"

def is_authenticated(auth_header):
    return True

def send_authorized(handler):
    handler.send_response(401)
    handler.end_headers()