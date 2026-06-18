#!/usr/bin/env python3
"""Launch the HarnessFlow Request Builder GUI.

One command, no install, no dependencies:

    python3 harness_gui.py

Starts a tiny local web server rooted at this folder and opens
``harness_gui.html`` in your default browser automatically. Serving over http
(instead of opening the file directly) lets the page live-sync the templates
from ``request_template/``. Press Ctrl+C to stop.

Set ``HARNESS_GUI_PORT`` to pin a port (default ``0`` picks a free one).
"""
import http.server
import os
import socketserver
import webbrowser

PAGE = "harness_gui.html"


def main():
    root = os.path.dirname(os.path.abspath(__file__))
    os.chdir(root)
    if not os.path.exists(PAGE):
        raise SystemExit("{} not found next to this script ({}).".format(PAGE, root))

    class Handler(http.server.SimpleHTTPRequestHandler):
        def log_message(self, *args):
            pass  # keep the console quiet

    port = int(os.environ.get("HARNESS_GUI_PORT", "0"))
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("127.0.0.1", port), Handler) as httpd:
        url = "http://127.0.0.1:{}/{}".format(httpd.server_address[1], PAGE)
        print("HarnessFlow Request Builder -> {}".format(url), flush=True)
        print("Press Ctrl+C to stop.", flush=True)
        webbrowser.open(url)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nStopped.")


if __name__ == "__main__":
    main()
