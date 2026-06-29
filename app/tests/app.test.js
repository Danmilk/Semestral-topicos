const request = require('supertest');
const { app, server } = require('../src/index');

afterAll(() => server.close());

describe('API routes', () => {
  test('GET / returns 200 with status ok', async () => {
    const res = await request(app).get('/');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });

  test('GET /health returns healthy status', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('healthy');
    expect(res.body).toHaveProperty('uptime');
  });

  test('GET /version returns version info', async () => {
    const res = await request(app).get('/version');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('version');
    expect(res.body).toHaveProperty('environment');
  });
});
