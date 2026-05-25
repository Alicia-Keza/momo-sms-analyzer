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
    


