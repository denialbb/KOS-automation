// test_drawer.js — Tests graph drawer toggle using the real telemetry server
const puppeteer = require('puppeteer');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const ROOT = path.join(__dirname, '..');
const SCREENSHOT_DIR = path.join(ROOT, 'dashboard', '.temp_diagnostics');

const sleep = ms => new Promise(r => setTimeout(r, ms));

async function waitForServer(port, timeout = 8000) {
    const http = require('http');
    const deadline = Date.now() + timeout;
    return new Promise((resolve, reject) => {
        const attempt = () => {
            http.get(`http://localhost:${port}/`, res => resolve()).on('error', () => {
                if (Date.now() > deadline) return reject(new Error('Server did not start'));
                setTimeout(attempt, 300);
            });
        };
        attempt();
    });
}

async function run() {
    // Start the real telemetry server
    const server = spawn('node', ['telemetry_server/server.js'], { cwd: ROOT, stdio: 'pipe' });
    server.stdout.on('data', d => process.stdout.write('[SRV] ' + d));
    server.stderr.on('data', d => process.stderr.write('[SRV ERR] ' + d));

    console.log('[INFO] Waiting for telemetry server...');
    await waitForServer(8080);
    console.log('[OK] Server is up.');

    const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox'] });
    const page = await browser.newPage();
    await page.setViewport({ width: 1440, height: 900 });

    page.on('pageerror', err => console.error(`[PAGE ERROR] ${err.message}`));

    await page.goto('http://localhost:8080/', { waitUntil: 'domcontentloaded', timeout: 15000 });
    await sleep(1500); // let scripts initialize
    console.log('[OK] Page loaded');

    // --- Inspect drawer state BEFORE click ---
    const before = await page.evaluate(() => {
        const drawer = document.getElementById('graph-drawer');
        const btn = document.querySelector('.graph-drawer-toggle');
        const centerHud = document.querySelector('.center-hud');
        const btnRect = btn ? btn.getBoundingClientRect() : null;
        const elAtBtn = btnRect ? document.elementFromPoint(btnRect.left + btnRect.width/2, btnRect.top + btnRect.height/2) : null;

        // Walk overflow chain from drawer upward
        const overflowChain = [];
        let el = drawer?.parentElement;
        while (el && el.tagName !== 'BODY') {
            const s = window.getComputedStyle(el);
            overflowChain.push({ tag: el.tagName, cls: el.className.split(' ')[0], overflow: s.overflow });
            el = el.parentElement;
        }

        return {
            drawerHeight: drawer?.offsetHeight,
            drawerClasses: drawer?.className,
            btnFound: !!btn,
            btnRect,
            btnVisible: btnRect ? (btnRect.width > 0 && btnRect.height > 0) : false,
            elAtBtn: elAtBtn ? `${elAtBtn.tagName}.${elAtBtn.className.split(' ')[0]}` : 'none',
            centerHudOverflow: centerHud ? window.getComputedStyle(centerHud).overflow : 'n/a',
            overflowChain,
        };
    });

    console.log('[BEFORE]', JSON.stringify(before, null, 2));

    // Screenshot BEFORE
    fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
    const ts = Date.now();
    await page.screenshot({ path: path.join(SCREENSHOT_DIR, `drawer_before_${ts}.png`) });
    console.log(`[OK] Screenshot BEFORE: drawer_before_${ts}.png`);

    // --- Click toggle button via JS ---
    await page.evaluate(() => {
        document.querySelector('.graph-drawer-toggle')?.click();
    });
    await sleep(600); // wait for CSS transition

    // --- Inspect drawer state AFTER click ---
    const after = await page.evaluate(() => {
        const drawer = document.getElementById('graph-drawer');
        return { drawerHeight: drawer?.offsetHeight, drawerClasses: drawer?.className };
    });
    console.log('[AFTER]', JSON.stringify(after, null, 2));

    await page.screenshot({ path: path.join(SCREENSHOT_DIR, `drawer_after_${ts}.png`) });
    console.log(`[OK] Screenshot AFTER: drawer_after_${ts}.png`);

    console.log('\n--- RESULT ---');
    if (after.drawerHeight > 0) {
        console.log('[PASS] Drawer EXPANDED correctly. Height:', after.drawerHeight);
    } else {
        console.log('[FAIL] Drawer did NOT expand. Height still:', after.drawerHeight);
        console.log('[DIAGNOSIS] Check centerHudOverflow and overflowChain in BEFORE log.');
    }

    await browser.close();
    server.kill();
    console.log('[DONE]');
}

run().catch(err => { console.error('[FATAL]', err.message); process.exit(1); });
