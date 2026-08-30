const test = require('node:test');
const assert = require('node:assert/strict');
const { server } = require('./server');

test('health endpoint returns ok', async () => {
  await new Promise((resolve) => server.listen(0, resolve));
  const { port } = server.address();
  const response = await fetch(`http://127.0.0.1:${port}/health`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: 'ok' });
  await new Promise((resolve) => server.close(resolve));
});
