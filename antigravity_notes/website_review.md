# DASA Telemetry Dashboard - Bug Report & Fixes

## 1. Orbital Viewer: Planet Showing a Green Circle (Image Caching Issue)
**Issue:** The planet in the orbital viewer is displaying a simple green circle instead of the line art. This is likely because the browser is serving a cached version of an older placeholder image. While cache-busting headers were correctly added for JSON and CSS files in `server.js`, they were missing for the image file.

**Fix:** Update the `/kerbin_line_art.png` route in `server.js` to include cache-control headers.

```javascript
// Serve Kerbin texture
app.get('/kerbin_line_art.png', (req, res) => {
    const filePath = path.join(__dirname, '..', 'dashboard', 'kerbin_line_art.png');
    if (fs.existsSync(filePath)) {
        // Add these headers to prevent caching
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        res.setHeader('Content-Type', 'image/png');
        res.sendFile(filePath);
    } else {
        res.status(404).send('Not found');
    }
});