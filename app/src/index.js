const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Proyecto Final - Azure Pipelines</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #0078d4 0%, #005a9e 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
    }
    .card {
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255,255,255,0.2);
      border-radius: 16px;
      padding: 48px;
      max-width: 600px;
      width: 90%;
      text-align: center;
    }
    .badge {
      background: #00b294;
      color: white;
      padding: 4px 14px;
      border-radius: 20px;
      font-size: 13px;
      font-weight: 600;
      display: inline-block;
      margin-bottom: 24px;
    }
    h1 { font-size: 2rem; margin-bottom: 8px; }
    .subtitle { opacity: 0.8; margin-bottom: 36px; font-size: 1rem; }
    .info-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
      margin-bottom: 32px;
    }
    .info-box {
      background: rgba(255,255,255,0.1);
      border-radius: 10px;
      padding: 16px;
    }
    .info-box .label { font-size: 11px; opacity: 0.7; text-transform: uppercase; letter-spacing: 1px; }
    .info-box .value { font-size: 1.1rem; font-weight: 600; margin-top: 4px; }
    .links { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
    .link-btn {
      background: rgba(255,255,255,0.2);
      color: white;
      text-decoration: none;
      padding: 10px 22px;
      border-radius: 8px;
      font-size: 14px;
      font-weight: 500;
      transition: background 0.2s;
    }
    .link-btn:hover { background: rgba(255,255,255,0.3); }
    .status-dot {
      display: inline-block;
      width: 10px; height: 10px;
      background: #00b294;
      border-radius: 50%;
      margin-right: 6px;
      animation: pulse 2s infinite;
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.4; }
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">Azure Container Instance</div>
    <h1>Proyecto Final</h1>
    <p class="subtitle">CI/CD con Azure Pipelines, Docker y Terraform</p>
    <div class="info-grid">
      <div class="info-box">
        <div class="label">Estado</div>
        <div class="value"><span class="status-dot"></span>Running</div>
      </div>
      <div class="info-box">
        <div class="label">Version</div>
        <div class="value">${process.env.APP_VERSION || '1.0.0'}</div>
      </div>
      <div class="info-box">
        <div class="label">Entorno</div>
        <div class="value">${process.env.NODE_ENV || 'development'}</div>
      </div>
      <div class="info-box">
        <div class="label">Uptime</div>
        <div class="value">${Math.floor(process.uptime())}s</div>
      </div>
    </div>
    <div class="links">
      <a class="link-btn" href="/health">/health</a>
      <a class="link-btn" href="/version">/version</a>
    </div>
  </div>
</body>
</html>`);
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', uptime: process.uptime(), timestamp: new Date().toISOString() });
});

app.get('/version', (req, res) => {
  res.json({ version: process.env.APP_VERSION || '1.0.0', environment: process.env.NODE_ENV || 'development' });
});

const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = { app, server };
