# This file is all about simple login check for the MOMO API.

# What this file does:
# 1. loads the username and password from the .env file
# 2. is_authorized() function checks if a request has the correct login
# 3. send_unauthorized() function sends back 401 error when login fails

import base64
import json
import os
import sys

# Get the API username and the password from the environment (from .env file)
VALID_USERNAME = os.environ.get("API_USERNAME")
VALID_PASSWORD = os.environ.get("API_PASSWORD")

#if they are missing, stop the program and show an error
if not VALID_USERNAME or not VALID_PASSWORD:
    sys.stderr.write("ERROR: Please set API_USERNAME and API_PASSWORD in your .env file.\n")
    sys.exit(1)

#Check if the user sent the correct username and password
def is_authorized(auth_header):

    #the header must exist and start with the word "Basic "
    if not auth_header or not auth_header.startswith("Basic "):
        return False

    try:
        #Take the part after "Basic " (this is the coded username:password)
        encoded = auth_header.split(" ",1)[1].strip()

        #change it back to normal text like "admin:password123"
        decoded = base64.b64decode(encoded).decode("utf-8")

        #split it into two parts at the ":"
        username, password = decoded.split(":", 1)

    except Exception:
        #if anything goes wrong, just say "not allowed"
        return False

    #allow only if both the username and password match
    return username == VALID_USERNAME and password == VALID_PASSWORD


#send back 401 error in JSON when login fails
def send_unauthorized(handler):
    #create the error message that will be sent back to the user when login fails
    payload = json.dumps({"error": "Unauthorized"}).encode("utf-8")

    #tell the browser that the request was not allowed
    handler.send_response(401)
    handler.send_header("WWW-Authenticate", 'Basic realm="MOMO API"')
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header( "Content-Length", str(len(payload)))
    handler.end_headers()

    #send the actual error message back
    handler.wfile.write(payload)


