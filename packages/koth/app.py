#!/usr/bin/env python3

import http.server
import socketserver
import os
import sys
from urllib.parse import urlparse

class KingHandler(http.server.BaseHTTPRequestHandler):
    """Custom HTTP handler to serve king.txt file contents"""
    
    def __init__(self, *args, **kwargs):
        self.king_file_path = '/king.txt'
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        """Handle GET requests"""
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/':
            self.serve_king_file()
        else:
            self.send_not_found()
    
    def serve_king_file(self):
        """Read and serve the king.txt file"""
        try:
            with open(self.king_file_path, 'r', encoding='utf-8') as file:
                content = file.read()
                
            # Send successful response
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.send_header('Content-Length', str(len(content.encode('utf-8'))))
            self.end_headers()
            self.wfile.write(content.encode('utf-8'))
            
        except FileNotFoundError:
            # File doesn't exist
            self.send_response(404)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'File not found')
            
        except PermissionError:
            # Permission denied
            self.send_response(500)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Internal server error')
            
        except Exception as e:
            # Other errors
            print(f"Error reading king.txt: {e}", file=sys.stderr)
            self.send_response(500)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Internal server error')
    
    def send_not_found(self):
        """Send 404 Not Found response"""
        self.send_response(404)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'Not found')
    
    def log_message(self, format, *args):
        """Override to customize log format"""
        timestamp = self.log_date_time_string()
        print(f"[{timestamp}] {format % args}")

def main():
    PORT = 9999
    
    try:
        with socketserver.TCPServer(("", PORT), KingHandler) as httpd:
            print(f"Server is running on port {PORT}")
            print(f"Serving king.txt from: {os.path.abspath('/king.txt')}")
            print("Press Ctrl+C to stop the server")
            httpd.serve_forever()
            
    except PermissionError:
        print(f"Error: Permission denied. Cannot bind to port {PORT}")
        print("Try running with sudo or use a port number above 1024")
        sys.exit(1)
        
    except OSError as e:
        print(f"Error starting server: {e}")
        sys.exit(1)
        
    except KeyboardInterrupt:
        print("\nShutting down server...")
        sys.exit(0)

if __name__ == '__main__':
    main()