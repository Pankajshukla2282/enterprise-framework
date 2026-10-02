// Hospital site — serves a static frontend and proxies /api/* to the
// hospital-service running in the EMTAF cluster (port-forwarded).
// Config via environment variables:
//   PORT         (default 3001)
//   API_BASE     (default http://localhost:8080)
//   JWT_TOKEN    (required — output of mint-dev-token.mjs)
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import url from 'node:url';

const __dirname = path.dirname(url.fileURLToPath(import.meta.url));
const PORT = Number(process.env.PORT || 3001);
const API_BASE = process.env.API_BASE || 'http://localhost:8080';
const JWT_TOKEN = process.env.JWT_TOKEN || '';
const MIME = { '.html': 'text/html', '.css': 'text/css', '.js': 'application/javascript' };

const server = http.createServer(async (req, res) => {
  const u = new URL(req.url, `http://${req.headers.host}`);
  if (u.pathname.startsWith('/api/')) {
    try {
      const upstream = await fetch(`${API_BASE}${u.pathname}${u.search}`, {
        method: req.method,
        headers: {
          'content-type': req.headers['content-type'] || 'application/json',
          authorization: `Bearer ${JWT_TOKEN}`,
        },
        body: ['GET', 'HEAD'].includes(req.method) ? undefined : await readBody(req),
      });
      res.writeHead(upstream.status, { 'content-type': upstream.headers.get('content-type') || 'application/json', 'access-control-allow-origin': '*' });
      res.end(Buffer.from(await upstream.arrayBuffer()));
    } catch (e) {
      res.writeHead(502); res.end(JSON.stringify({ error: e.message }));
    }
    return;
  }
  if (req.method === 'OPTIONS') { res.writeHead(204, { 'access-control-allow-origin': '*', 'access-control-allow-headers': 'authorization,content-type' }); res.end(); return; }
  const file = u.pathname === '/' ? '/index.html' : u.pathname;
  const p = path.join(__dirname, 'public', file);
  if (!p.startsWith(path.join(__dirname, 'public')) || !fs.existsSync(p)) { res.writeHead(404); res.end('Not found'); return; }
  res.writeHead(200, { 'content-type': MIME[path.extname(p)] || 'text/plain' });
  fs.createReadStream(p).pipe(res);
});
function readBody(req) { return new Promise((r) => { let b = ''; req.on('data', (c) => (b += c)); req.on('end', () => r(b)); }); }
server.listen(PORT, () => console.log(`Hospital site → http://localhost:${PORT}`));
