import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

# importing of authentication module
from api.auth import is_authorized, send_unauthorized, VALID_USERNAME

# import of data module
from api import crud

class MoMoHandler(BaseHTTPRequestHandler):

    # helper methods

    def send_json(self, status, body):
        text = json.dumps(body, indent=2)
        data = text.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def read_json_body(self):
        length = int(self.headers.get("Content-Length", 0))
        if length <= 0:
            return None
        raw = self.rfile.read(length)
        try:
            return json.loads(raw)
        except (json.JSONDecodeError, ValueError):
            return None
        
    def check_auth(self):
        if is_authorized(self.headers.get("Authorization")):
            return True
        send_unauthorized(self)
        return False
    
    def get_id_from_path(self):
        parts = self.path.split("/")
        if len(parts) >= 3 and parts[1] == "transactions" and parts[2].isdigit():
            return int(parts[2])
        return None
    

    # routes

    def do_GET(self):
        if not self.check_auth():
            return

        if self.path == "/transactions":
            self.send_json(200, crud.list_all())
            return
        
        tx_id = self.get_id_from_path()
        if tx_id is not None:
            record = crud.get_by_id(tx_id)
            if record is None:
                self.send_json(404, {"error": "Transaction not found"})
            else:
                self.send_json(200, record)
            return
        
        self.send_json(404, {"error": "Route not found"})


    def do_POST(self):
        if not self.check_auth():
            return
        
        if self.path != "/transactions":
            self.send_json(404, {"error": "Route not found"})
            return
        
        body = self.read_json_body()
        if body is None:
            self.send_json(400, {"error": "Invalid JSON body"})
            return
        
        record = crud.create(body)
        self.send_json(201, record)


    def do_PUT(self):
        if not self.check_auth():
            return
        
        tx_id = self.get_id_from_path()
        if tx_id is None:
            self.send_json(404, {"error": "Route not found"})
            return
        
        body = self.read_json_body()
        if body is None:
            self.send_json(400, {"error": "Invalid JSON"})
            return
        
        updated = crud.update(tx_id, body)
        if updated is None:
            self.send_json(404, {"error": "Transaction not found"})
        else:
            self.send_json(200, updated)

    def do_DELETE(self):
        if not self.check_auth():
            return

        tx_id = self.get_id_from_path()
        if tx_id is None:
            self.send_json(404, {"error": "Route not found"})
            return

        deleted_id = crud.delete(tx_id)
        if deleted_id is None:
            self.send_json(404, {"error": "Transaction not found"})
        else:
            self.send_json(200, {"deleted": deleted_id})


def run():
    port = int(os.environ.get("API_PORT", "8000"))
    server = HTTPServer(("", port), MoMoHandler)
    print("MoMo API Server is running on port", port)
    print("Records loaded: ", len(crud.list_all()))
    print("Authenticated user: ", VALID_USERNAME)
    print("Press Ctrl+C to stop the server.")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down server...")
        server.server_close()

if __name__ == "__main__":
    run()