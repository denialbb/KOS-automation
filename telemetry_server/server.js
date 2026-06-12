const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 8080;

let wasConnected = true;
let lastKnownTime = 0;

function formatTime(t) {
    const hours = Math.floor(t / 3600);
    const mins = Math.floor((t % 3600) / 60);
    const secs = Math.floor(t % 60);
    return `[T+ ${String(hours).padStart(2, '0')}:${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}]`;
}

function logEvent(message) {
    const logPath = path.join(__dirname, '..', 'logs', 'log.txt');
    try {
        fs.appendFileSync(logPath, message + '\n');
    } catch (e) {
        console.error("Failed to write to log", e);
    }
}

// Serve static dashboard
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'dashboard', 'telemetry_dashboard.html'));
});

// Serve favicon
app.get('/favicon.ico', (req, res) => {
    res.status(204).end();
});

// Serve stylesheet
app.get('/telemetry_dashboard.css', (req, res) => {
    const filePath = path.join(__dirname, '..', 'dashboard', 'telemetry_dashboard.css');
    if (fs.existsSync(filePath)) {
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        res.setHeader('Content-Type', 'text/css');
        res.sendFile(filePath);
    } else {
        res.status(404).send('Not found');
    }
});

// Serve telemetry.json
app.get('/telemetry.json', (req, res) => {
    const filePath = path.join(__dirname, '..', 'telemetry', 'telemetry.json');
    if (fs.existsSync(filePath)) {
        const stats = fs.statSync(filePath);
        const ageMs = Date.now() - stats.mtimeMs;
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        
        if (ageMs > 3000) {
            try {
                const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
                if (data.paused) {
                    // Game is paused — not a signal loss
                    data.signalLost = false;
                    res.json(data);
                } else {
                    if (wasConnected) {
                        wasConnected = false;
                        logEvent(`${formatTime(lastKnownTime)} SIGNAL LOST: Connection to KOS computer lost.`);
                    }
                    data.signalLost = true;
                    res.json(data);
                }
            } catch (err) {
                if (wasConnected) {
                    wasConnected = false;
                    logEvent(`${formatTime(lastKnownTime)} SIGNAL LOST: Connection to KOS computer lost.`);
                }
                res.json({ signalLost: true });
            }
        } else {
            try {
                const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
                if (data.time !== undefined) {
                    lastKnownTime = data.time;
                }
                if (!wasConnected) {
                    wasConnected = true;
                    logEvent(`${formatTime(lastKnownTime)} Signal restored. Reconnected to KOS computer.`);
                }
                res.json(data);
            } catch (err) {
                res.sendFile(filePath);
            }
        }
    } else {
        res.json({ signalLost: true });
    }
});

// Serve vessel_structure.json
app.get('/vessel_structure.json', (req, res) => {
    const filePath = path.join(__dirname, '..', 'telemetry', 'vessel_structure.json');
    if (fs.existsSync(filePath)) {
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        res.sendFile(filePath);
    } else {
        res.json({ parts: [] });
    }
});

// Serve deployables_cache.json
app.get('/deployables_cache.json', (req, res) => {
    const filePath = path.join(__dirname, '..', 'telemetry', 'deployables_cache.json');
    if (fs.existsSync(filePath)) {
        res.setHeader('Cache-Control', 'no-store'); res.sendFile(filePath);
    } else { res.json({}); }
});

// Serve vessel_mesh.json
app.get('/vessel_mesh.json', (req, res) => {
    const filePath = path.join(__dirname, '..', 'telemetry', 'vessel_mesh.json');
    if (fs.existsSync(filePath)) {
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        res.sendFile(filePath);
    } else {
        res.json({});
    }
});

const { WebSocketServer } = require('ws');

const server = app.listen(PORT, () => {
    console.log(`Node.js Telemetry Server running at http://localhost:${PORT}`);
});

const wss = new WebSocketServer({ server });

const telemetryFilePath = path.join(__dirname, '..', 'telemetry', 'telemetry.json');
if (fs.existsSync(telemetryFilePath)) {
    fs.watch(telemetryFilePath, () => {
        try {
            const fileContent = fs.readFileSync(telemetryFilePath, 'utf8');
            if (!fileContent.trim()) return;
            const data = JSON.parse(fileContent);
            
            // Check paused state like in the GET endpoint
            const ageMs = Date.now() - fs.statSync(telemetryFilePath).mtimeMs;
            if (ageMs > 3000) {
                if (data.paused) {
                    data.signalLost = false;
                } else {
                    data.signalLost = true;
                }
            }
            
            wss.clients.forEach(client => {
                if (client.readyState === 1) {
                    client.send(JSON.stringify(data));
                }
            });
        } catch (err) {
            // file might be in the middle of being written, ignore
        }
    });
}
