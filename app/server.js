const http = require('node:http');
const { Client } = require('pg');

const port = Number(process.env.PORT || 3000);

function respond(res, status, body) {
  res.writeHead(status, { 'content-type': 'application/json' });
  res.end(JSON.stringify(body));
}

async function databaseHealthy() {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) return { configured: false };
  const client = new Client({ connectionString, connectionTimeoutMillis: 3000 });
  try {
    await client.connect();
    await client.query('SELECT 1');
    return { configured: true, connected: true };
  } finally {
    await client.end().catch(() => undefined);
  }
}

const server = http.createServer(async (req, res) => {
  if (req.url === '/health') return respond(res, 200, { status: 'ok' });
  if (req.url === '/db-health') {
    try {
      return respond(res, 200, await databaseHealthy());
    } catch (error) {
      console.error('database health check failed', error.message);
      return respond(res, 503, { status: 'unavailable' });
    }
  }
  return respond(res, 200, { service: '8byte-devops-assignment', endpoints: ['/health', '/db-health'] });
});

if (require.main === module) server.listen(port, () => console.log(`listening on ${port}`));
module.exports = { server };
