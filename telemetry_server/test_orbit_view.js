const puppeteer = require('puppeteer');
const path = require('path');

async function runTest() {
    const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    try {
        const page = await browser.newPage();
        await page.setViewport({ width: 1920, height: 1080 });

        console.log("Navigating to http://localhost:8080/");
        await page.goto('http://localhost:8080/', { waitUntil: 'networkidle2' });

        // Switch to orbital view. The orbit button might be a radio or button.
        // I'll evaluate a script to click the orbit view.
        console.log("Switching to orbit view...");
        await page.evaluate(() => {
            const orbitBtn = Array.from(document.querySelectorAll('.view-toggle button')).find(el => el.textContent.trim().toLowerCase() === 'orbit');
            if (orbitBtn) orbitBtn.click();
        });

        // Wait a bit for the drawing to happen
        await new Promise(r => setTimeout(r, 2000));

        // Let's inspect kerbinTex
        console.log("Inspecting kerbinTex...");
        const imgInfo = await page.evaluate(() => {
            if (typeof kerbinTex !== 'undefined') {
                return {
                    src: kerbinTex.src,
                    complete: kerbinTex.complete,
                    naturalWidth: kerbinTex.naturalWidth,
                    naturalHeight: kerbinTex.naturalHeight
                };
            }
            return "kerbinTex is not defined";
        });
        console.log("kerbinTex info:", imgInfo);

        // Take screenshot
        const screenshotPath = path.join(__dirname, '..', 'dashboard', 'orbit_test_screenshot.png');
        await page.screenshot({ path: screenshotPath });
        console.log("Screenshot saved to", screenshotPath);

    } catch (err) {
        console.error(err);
    } finally {
        await browser.close();
    }
}

runTest();
