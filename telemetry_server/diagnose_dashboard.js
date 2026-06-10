const fs = require('fs');
const path = require('path');
const net = require('net');
const { spawn, execSync } = require('child_process');

const PORT = 8080;
const rootDir = path.resolve(__dirname, '..');

// Helper to check if a port is in use
function checkPort(port) {
    return new Promise((resolve) => {
        const server = net.createServer();
        server.once('error', (err) => {
            if (err.code === 'EADDRINUSE') {
                resolve(false); // Port is occupied
            } else {
                resolve(true); // Other error, assume port free or checkable
            }
        });
        server.once('listening', () => {
            server.close(() => resolve(true)); // Port is free
        });
        server.listen(port);
    });
}

// Main execution function
async function runDiagnostics() {
    console.log("==================================================");
    console.log("   DASA Telemetry Dashboard Diagnostics Tool");
    console.log("==================================================");

    // 1. Check Port 8080 Availability
    const isPortFree = await checkPort(PORT);
    if (!isPortFree) {
        console.error(`\n[FATAL ERROR] Port ${PORT} is already in use by another process.`);
        console.error("Please shut down any existing servers or dashboards running on this port and try again.");
        process.exit(1);
    }
    console.log(`[OK] Port ${PORT} is free.`);

    // 2. Ensure Puppeteer is installed
    const puppeteerPath = path.join(__dirname, 'node_modules', 'puppeteer');
    if (fs.existsSync(puppeteerPath)) {
        console.log("[OK] Puppeteer is already installed.");
    } else {
        console.log("[INFO] Puppeteer is missing. Attempting automatic installation...");
        try {
            execSync('npm install puppeteer', {
                cwd: __dirname,
                stdio: 'inherit'
            });
            console.log("[OK] Puppeteer installed successfully.");
        } catch (err) {
            console.error("\n[FATAL ERROR] Failed to automatically install Puppeteer:", err.message);
            console.error("Please run 'npm install puppeteer' manually inside 'telemetry_server/' directory.");
            process.exit(1);
        }
    }

    // 3. Start Telemetry Server in the Background
    console.log("[INFO] Spawning telemetry server...");
    const psScript = path.join(rootDir, 'start_telemetry_server.ps1');
    const serverProcess = spawn('powershell.exe', [
        '-ExecutionPolicy', 'Bypass',
        '-File', psScript
    ], {
        cwd: rootDir,
        stdio: 'pipe'
    });

    let serverStarted = false;
    serverProcess.stdout.on('data', (data) => {
        const output = data.toString();
        if (output.includes("Telemetry Server running") || output.includes("running at http")) {
            serverStarted = true;
        }
        process.stdout.write(`[Server stdout] ${output}`);
    });

    serverProcess.stderr.on('data', (data) => {
        process.stderr.write(`[Server stderr] ${data.toString()}`);
    });

    // Wait up to 5 seconds for the server to report it's running
    for (let i = 0; i < 50; i++) {
        if (serverStarted) break;
        await new Promise(r => setTimeout(r, 100));
    }

    if (!serverStarted) {
        console.error("\n[FATAL ERROR] Telemetry server failed to start within 5 seconds.");
        serverProcess.kill();
        process.exit(1);
    }
    console.log("[OK] Telemetry server is up and listening.");

    // 4. Launch Puppeteer Diagnostics
    const puppeteer = require('puppeteer');
    console.log("[INFO] Launching headless browser...");
    const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    const page = await browser.newPage();
    const logs = [];
    const exceptions = [];
    const netErrors = [];

    // Hook browser events
    page.on('console', msg => {
        const text = msg.text();
        const type = msg.type();
        logs.push({ type, text });
        console.log(`[Browser ${type.toUpperCase()}] ${text}`);
    });

    page.on('pageerror', err => {
        exceptions.push(err.message || err);
        console.error(`[Browser EXCEPTION] ${err.message || err}`);
    });

    page.on('requestfailed', request => {
        const url = request.url();
        const failure = request.failure();
        const errText = failure ? failure.errorText : 'Unknown';
        netErrors.push({ url, errorText: errText });
        console.error(`[Browser NET ERROR] Failed to load ${url}: ${errText}`);
    });

    page.on('response', response => {
        const status = response.status();
        if (status >= 400) {
            const url = response.url();
            netErrors.push({ url, errorText: `HTTP ${status}` });
            console.error(`[Browser NET ERROR] HTTP ${status}: ${url}`);
        }
    });

    try {
        console.log("[INFO] Navigating to dashboard...");
        // Set the viewport to standard fullscreen dimensions
        await page.setViewport({ width: 1920, height: 1080 });
        await page.goto(`http://localhost:${PORT}/`, { waitUntil: 'networkidle2' });
        console.log("[OK] Navigation complete.");

        // Click the Historical Graphs section to expand/open it
        console.log("[INFO] Clicking Historical Graphs toggle...");
        await page.click('.graph-drawer-toggle');

        // Wait 20 seconds for game telemetry and user interaction
        console.log("[INFO] Listening to dashboard for 20 seconds. Please feed telemetry from KSP if active...");
        await new Promise(resolve => setTimeout(resolve, 20000));

        // 5. Capture Screenshot
        const screenshotDir = path.join(rootDir, 'dashboard', '.temp_diagnostics');
        if (!fs.existsSync(screenshotDir)) {
            fs.mkdirSync(screenshotDir, { recursive: true });
        }
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const screenshotPath = path.join(screenshotDir, `screenshot-${timestamp}.png`);
        await page.screenshot({ path: screenshotPath });
        console.log(`[OK] Screenshot captured and saved to: ${screenshotPath}`);

    } catch (err) {
        console.error("[ERROR] Error occurred during browser diagnostics:", err.message);
        exceptions.push(err.message);
    } finally {
        // Close browser
        await browser.close();
        console.log("[INFO] Browser closed.");

        // Shut down server
        console.log("[INFO] Terminating telemetry server...");
        serverProcess.kill();
        
        // Give OS a second to release the port
        await new Promise(r => setTimeout(r, 1000));
        
        // Final report printout
        console.log("\n==================================================");
        console.log("              DIAGNOSTIC SUMMARY REPORT");
        console.log("==================================================");
        
        const errorsCount = exceptions.length + netErrors.length + logs.filter(l => l.type === 'error').length;
        const warningsCount = logs.filter(l => l.type === 'warning').length;

        console.log(`Fatal Javascript Exceptions: ${exceptions.length}`);
        console.log(`Network Load Failures:      ${netErrors.length}`);
        console.log(`Console Errors:             ${logs.filter(l => l.type === 'error').length}`);
        console.log(`Console Warnings:           ${warningsCount}`);
        console.log("--------------------------------------------------");

        if (errorsCount > 0) {
            console.error("[RESULT] Troubleshooting finished. ISSUES FOUND!");
            if (exceptions.length > 0) {
                console.error("\n--- Exceptions ---");
                exceptions.forEach((e, idx) => console.error(`  ${idx + 1}. ${e}`));
            }
            if (netErrors.length > 0) {
                console.error("\n--- Network Errors ---");
                netErrors.forEach((n, idx) => console.error(`  ${idx + 1}. ${n.url} (${n.errorText})`));
            }
            const consoleErrors = logs.filter(l => l.type === 'error');
            if (consoleErrors.length > 0) {
                console.error("\n--- Console Errors ---");
                consoleErrors.forEach((c, idx) => console.error(`  ${idx + 1}. ${c.text}`));
            }
            process.exit(1);
        } else {
            console.log("[RESULT] Troubleshooting finished. NO ERRORS FOUND!");
            if (warningsCount > 0) {
                console.log("\n--- Console Warnings ---");
                logs.filter(l => l.type === 'warning').forEach((w, idx) => console.log(`  ${idx + 1}. ${w.text}`));
            }
            process.exit(0);
        }
    }
}

runDiagnostics().catch(err => {
    console.error("Unhandled top-level error in diagnostic run:", err);
    process.exit(1);
});
