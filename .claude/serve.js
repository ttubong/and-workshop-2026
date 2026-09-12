// Minimal static file server for local checks before deploying.
// `python3 -m http.server` cannot start under the sandbox (getcwd is blocked),
// so this serves the same files with node instead.
const http = require('http');
const fs = require('fs');
const path = require('path');

const root = __dirname.replace(/\/\.claude$/, '');
const port = Number(process.env.PORT) || 4173;

const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.sql': 'text/plain; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.webp': 'image/webp',
  '.ico': 'image/x-icon',
};

http.createServer((req, res) => {
  let rel;
  try {
    rel = decodeURIComponent(req.url.split('?')[0]);
  } catch (e) {
    res.writeHead(400).end('bad request');
    return;
  }
  if (rel.endsWith('/')) rel += 'index.html';

  const abs = path.normalize(path.join(root, rel));
  // Never serve outside the project.
  if (abs !== root && !abs.startsWith(root + path.sep)) {
    res.writeHead(403).end('forbidden');
    return;
  }

  fs.readFile(abs, (err, data) => {
    if (err) {
      res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' }).end('not found');
      return;
    }
    res.writeHead(200, {
      'content-type': TYPES[path.extname(abs).toLowerCase()] || 'application/octet-stream',
      'cache-control': 'no-store',
    });
    res.end(data);
  });
}).listen(port, () => {
  console.log('serving ' + root + ' on http://localhost:' + port);
});
