import http.server
import os


PORT = 8080


class SimpleHandler(http.server.BaseHTTPRequestHandler):
  def do_HEAD(s):
    s.send_response(200)
    s.send_header('Content-type', 'text/html')
    s.end_headers()

  def do_GET(s):
    s.send_response(200)
    s.send_header('Content-type', 'text/html')
    s.end_headers()

    m = os.environ.get('TEXT', None) or 'Hello World'

    s.wfile.write(m.encode('utf_8'))


httpd = http.server.HTTPServer(('', PORT), SimpleHandler)

print('Serving at port:', PORT)

httpd.serve_forever()
