const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const path = require('path');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = process.env.PORT || 8080;

// Serve static files
app.use(express.static('public'));

// Main viewer page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'viewer.html'));
});

// WebSocket connection handling
const clients = new Set();
let simulationClient = null;

wss.on('connection', (ws, req) => {
  console.log('New WebSocket connection');

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);

      if (data.type === 'simulation') {
        // This is the simulation client sending video frames
        simulationClient = ws;
        console.log('Simulation client connected');
      } else if (data.type === 'viewer') {
        // This is a viewer client
        clients.add(ws);
        console.log(`Viewer connected. Total viewers: ${clients.size}`);
      } else if (data.type === 'frame' && simulationClient === ws) {
        // Forward frame to all viewers
        clients.forEach(client => {
          if (client.readyState === WebSocket.OPEN) {
            client.send(message);
          }
        });
      } else if (data.type === 'control') {
        // Forward control messages to simulation
        if (simulationClient && simulationClient.readyState === WebSocket.OPEN) {
          simulationClient.send(message);
        }
      }
    } catch (error) {
      console.error('Error processing message:', error);
    }
  });

  ws.on('close', () => {
    if (ws === simulationClient) {
      console.log('Simulation client disconnected');
      simulationClient = null;
    } else {
      clients.delete(ws);
      console.log(`Viewer disconnected. Total viewers: ${clients.size}`);
    }
  });

  ws.on('error', (error) => {
    console.error('WebSocket error:', error);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`WebRTC Viewer Server running on port ${PORT}`);
  console.log(`Open http://localhost:${PORT} in your browser`);
  console.log(`Or access remotely at http://<your-server-ip>:${PORT}`);
});
