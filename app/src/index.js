const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Final Project API - Azure Pipelines',
    version: process.env.APP_VERSION || '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/version', (req, res) => {
  res.json({
    version: process.env.APP_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = { app, server };
