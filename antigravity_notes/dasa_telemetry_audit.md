# DASA Telemetry Dashboard — Audit Report

> **Scope:** `telemetry_dashboard.html`, `telemetry_dashboard.css`, `server.js`, `mu_mesh_export.py`
> **Format:** Each item has a unique ID, severity, exact file/line location, diagnosis, and a ready-to-apply fix or implementation spec.

---

## Legend

| Severity | Meaning |
|----------|---------|
| `CRITICAL` | Silent failure or data corruption visible to user |
| `HIGH` | Meaningful performance or correctness problem |
| `MEDIUM` | Incorrect behaviour under specific conditions |
| `LOW` | Code quality, dead code, minor UX polish |
| `FEATURE` | New capability to add; spec is implementation-ready |

---

## Part 1 — Bugs

---

### BUG-01 · CRITICAL · `telemetry_dashboard.css` line ~156 + `telemetry_dashboard.html` lines 805–815

**Title:** `--danger` and `--success` CSS variables used in JS but never declared — signal-lost badge renders with no colour change.

**Diagnosis:** `updateHUD` (and the signal-status block in `fetchTelemetry`) sets `connStatus.style.color = "var(--danger)"` and `"var(--success)"`. Neither variable exists in `:root`, so the browser resolves them to the initial value and the badge appears unchanged.

**Fix:** Add to `:root` in `telemetry_dashboard.css`:

```css
--danger: #ef4444;
--success: #10b981;
```

---

### BUG-02 · CRITICAL · `telemetry_dashboard.html` lines 855–873 (inside `updateHUD`)

**Title:** Resources panel DOM rebuilt every animation frame (60 fps DOM thrashing).

**Diagnosis:** `updateHUD()` is called from `requestAnimationFrame`. It unconditionally clears `resContainer.innerHTML` and reconstructs all gauge `<div>` elements on every frame. At 60 fps that is ~3,600 full DOM rebuilds per minute for data that changes at most 5 Hz.

**Fix:** Introduce a dirty flag. Set `resourcesDirty = true` inside `fetchTelemetry` whenever `data.resources` arrives. In `updateHUD`, guard the rebuild block:

```js
let resourcesDirty = false; // add to global state section

// inside fetchTelemetry, after receiving data.resources:
resourcesDirty = true;

// inside updateHUD, replace the unconditional block with:
if (resourcesDirty && d.resources) {
    resourcesDirty = false;
    // ... existing rebuild logic unchanged ...
}
```

---

### BUG-03 · HIGH · `telemetry_dashboard.html` lines 673–700

**Title:** Velocity unit-switch threshold (300 m/s) causes constant toggling at orbital speeds.

**Diagnosis:** The code flips between m/s and km/s display when `velocity` crosses 300 m/s. Kerbin orbital velocity is ~2,200 m/s, well above this, so the toggle fires during early ascent and never reverts cleanly. At re-entry speeds the toggle oscillates.

**Fix:** Raise the threshold to 9,999 m/s (just below Kerbin escape velocity), which is a meaningful km/s crossover point. Replace both threshold comparisons:

```js
// Line 674: change
if (!isVelKmS && rawVel >= 300) {
// to:
if (!isVelKmS && rawVel >= 9999) {

// Line 687: change
} else if (isVelKmS && rawVel < 300) {
// to:
} else if (isVelKmS && rawVel < 9999) {
```

---

### BUG-04 · HIGH · `telemetry_dashboard.html` lines 660–665 (inside `fetchTelemetry`)

**Title:** O(n²) part-UID lookup — `.find()` called inside `.forEach()` over two ~50-element arrays.

**Diagnosis:** For every telemetry packet, the code iterates all `vesselStructure.parts` and, for each, calls `activePartsCache.find(x => x.uid === p.uid)`. With 50 parts each that is 2,500 string comparisons per 200 ms packet.

**Fix:** Build a `Map` once per fetch, then do O(1) lookups:

```js
// Replace lines 660–665 with:
if (data.parts && data.parts.length > 0) {
    activePartsCache = data.parts;
    const activeLookup = new Map(data.parts.map(p => [p.uid, p]));
    if (vesselStructure && vesselStructure.parts) {
        vesselStructure.parts.forEach(p => {
            const ap = activeLookup.get(p.uid);
            if (ap) p.title = ap.title;
        });
    }
}
```

---

### BUG-05 · HIGH · `telemetry_dashboard.html` line 335

**Title:** Unknown resource colours are non-deterministic — different random colour on every page load.

**Diagnosis:** `getResourceColor` calls `Math.random()` for any resource not in `predefinedColors`. The colour is memoised for the session but resets on reload, so chart line colours are inconsistent between sessions and across tab refreshes.

**Fix:** Replace `Math.random()` with a deterministic string hash:

```js
function hashColor(str) {
    let hash = 5381;
    for (let i = 0; i < str.length; i++) hash = ((hash << 5) + hash) ^ str.charCodeAt(i);
    return '#' + ((hash >>> 0) % 0xFFFFFF).toString(16).padStart(6, '0');
}

function getResourceColor(name) {
    if (!predefinedColors[name]) predefinedColors[name] = hashColor(name);
    return predefinedColors[name];
}
```

---

### BUG-06 · MEDIUM · `telemetry_dashboard.html` line 1714

**Title:** `setInterval(fetchTelemetry, 200)` allows overlapping async fetches.

**Diagnosis:** If a fetch takes longer than 200 ms (server stall, slow disk read), the next interval fires before the previous resolves. Concurrent in-flight requests can arrive out-of-order and corrupt interpolation state.

**Fix:** Replace `setInterval` with a chained `setTimeout` that reschedules only after the previous fetch completes:

```js
// Remove: setInterval(fetchTelemetry, 200);
// Replace with:
async function scheduledFetch() {
    await fetchTelemetry();
    setTimeout(scheduledFetch, 200);
}
scheduledFetch();
```

---

### BUG-07 · MEDIUM · `telemetry_dashboard.html` lines 1641–1659

**Title:** Touch drag events scroll the page instead of rotating the vessel viewer.

**Diagnosis:** `touchstart` and `touchmove` are not calling `preventDefault()`, so the browser processes both the canvas gesture and the page scroll simultaneously.

**Fix:** Add `e.preventDefault()` to both handlers and mark the listeners as non-passive:

```js
canvas.addEventListener('touchstart', (e) => {
    e.preventDefault(); // ADD
    if (e.touches.length === 1) { ... }
}, { passive: false }); // ADD options

window.addEventListener('touchmove', (e) => {
    if (!isDragging || e.touches.length !== 1) return;
    e.preventDefault(); // ADD
    ...
}, { passive: false }); // ADD options
```

---

### BUG-08 · MEDIUM · `server.js` lines 62–79

**Title:** Stale-file detection (`ageMs > 3000`) cannot distinguish game-paused from genuine signal loss.

**Diagnosis:** When KSP is paused, the kOS script stops writing but the connection is intact. The server logs "SIGNAL LOST" after 3 seconds of any pause, flooding the log with false positives.

**Fix:** Emit a `"paused": true` field in the kOS telemetry script when `KUNIVERSE:TIMEWARP:RATE = 0` or the game is paused. In `server.js`, check for it:

```js
// In the ageMs > 3000 block:
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
```

---

### BUG-09 · LOW · `telemetry_dashboard.css` lines ~156–160

**Title:** Dead CSS property `flex-col: column` in `.left-sidebar`.

**Diagnosis:** `flex-col` is not a valid CSS property. The correct `flex-direction: column` is already declared on the next line. This is dead code.

**Fix:** Delete the line `flex-col: column;` from `.left-sidebar`.

---

### BUG-10 · LOW · `mu_mesh_export.py` lines 94–107 (`walk_obj`)

**Title:** `apply_transform()` is defined but never called; part rotation quaternions are silently ignored.

**Diagnosis:** `walk_obj` accumulates only positions (summing `localPosition`). `localScale` is applied, but the `localRotation` quaternion on each transform is never read or applied. Parts with non-trivial local rotations (fins, angled instruments) are rendered at incorrect orientations in the vessel viewer.

**Fix:** Apply the quaternion to each vertex before adding the accumulated position. Implement quaternion-vector rotation in `walk_obj`:

```python
def quat_rotate(q, v):
    """Rotate vector v by unit quaternion q = (x, y, z, w)."""
    qx, qy, qz, qw = q
    # t = 2 * cross(q.xyz, v)
    tx = 2*(qy*v[2] - qz*v[1])
    ty = 2*(qz*v[0] - qx*v[2])
    tz = 2*(qx*v[1] - qy*v[0])
    return (
        v[0] + qw*tx + qy*tz - qz*ty,
        v[1] + qw*ty + qz*tx - qx*tz,
        v[2] + qw*tz + qx*ty - qy*tx,
    )

# In walk_obj, replace the all_verts.append block:
for v in mesh.verts:
    sv = (v[0]*obj.transform.localScale[0],
          v[1]*obj.transform.localScale[1],
          v[2]*obj.transform.localScale[2])
    rv = quat_rotate(obj.transform.localRotation, sv)
    all_verts.append((rv[0]+pos[0], rv[1]+pos[1], rv[2]+pos[2]))
```

Note: `pos` should also be accumulated using quaternion rotation for full correctness if the hierarchy contains rotated parents. The full fix requires composing world-space transforms top-down; the patch above handles per-object rotation, which is the most common case.

---

### BUG-11 · LOW · `server.js` / `telemetry_dashboard.html`

**Title:** `deployables_cache.json` is written by kOS but has no server route and is never fetched by the dashboard.

**Diagnosis:** The file contains structured data on fairings, deployable modules, and science experiments per part UID. It is currently a dead output.

**Fix (server):** Add a route in `server.js` mirroring the `vessel_structure.json` pattern:

```js
app.get('/deployables_cache.json', (req, res) => {
    const filePath = path.join(__dirname, '..', 'telemetry', 'deployables_cache.json');
    if (fs.existsSync(filePath)) {
        res.setHeader('Cache-Control', 'no-store'); res.sendFile(filePath);
    } else { res.json({}); }
});
```

**Fix (client):** Add a `fetchDeployables()` function and call it at boot + every 5 seconds (same cadence as `fetchStructure`). Parse the kOS Lexicon format (flat key-value pairs in `entries[]`) into a usable lookup. This data feeds BUG-11 and FEATURE-05.

---

## Part 2 — Feature Additions

---

### FEATURE-01 · Orbit Diagram Panel

**Description:** A 2D orbital diagram rendered on a `<canvas>` element, showing the current orbital ellipse, vessel position, target position (if set), and maneuver node position.

**Data available in `telemetry.json`:** `apoapsis`, `periapsis`, `altitude`, `body`, `target.distance`, `maneuver.eta`, `maneuver.dv`.

**Implementation spec:**

- Add a new panel to the right sidebar (or as a third centre-column HUD mode button alongside "Attitude 3D" and "Blueprint").
- Render the ellipse from semi-major/semi-minor axes derived from Ap/Pe: `a = (apoapsis + periapsis) / 2 + R_body`, `b = sqrt(a * periapsis_r)` where `periapsis_r = periapsis + R_body`.
- Draw the parent body as a filled circle scaled to fit.
- Mark Ap/Pe with labelled tick marks.
- Place the vessel dot at the correct true anomaly, computed from altitude and the orbital elements.
- If `target.hasTarget`, draw a second ellipse or just a target marker at approximate angular offset.
- If `maneuver.hasNode`, draw a delta-v arrow at the node position.
- Kerbin body radius constant: **600,000 m**. Mun: **200,000 m**. Minmus: **60,000 m**. These should be in a `BODY_RADII` lookup object.

---

### FEATURE-02 · Maneuver Burn Timer

**Description:** Expand the existing maneuver node panel to show a proper burn window countdown.

**Data available:** `maneuver.eta` (seconds to node), `maneuver.dv` (m/s), `twr`, `body` (for surface gravity).

**Implementation spec:**

- Compute half-burn time: `t_half = dv / (twr * 9.81)` (use `9.81` as a safe Kerbin-normalised g; expose as a configurable constant).
- Display:
  - **Burn start:** `T − (eta − t_half)` formatted as `MM:SS`
  - **Burn stop:** `T − (eta + t_half)`
  - **Total burn duration:** `2 * t_half` in seconds
- Add a visual progress bar filling from 0% to 100% during the active burn window (when `eta < t_half`).
- Flash the maneuver panel amber when burn start is within 60 seconds. Flash red when within 10 seconds.

---

### FEATURE-03 · Critical Threshold Alert System

**Description:** A declarative alert system that monitors telemetry values and triggers visual and audio notifications when thresholds are crossed.

**Implementation spec:**

Define an `ALERTS` array in the global state section:

```js
const ALERTS = [
    { id: 'low_ec',   label: 'LOW ELECTRIC CHARGE', check: d => (d.resources?.ElectricCharge?.amount / d.resources?.ElectricCharge?.capacity) < 0.15, severity: 'critical' },
    { id: 'burn_soon', label: 'BURN IN 60s',         check: d => d.maneuver?.hasNode && d.maneuver.eta < 60,  severity: 'warning'  },
    { id: 'atmo_pe',  label: 'PERIAPSIS IN ATMO',    check: d => d.body === 'Kerbin' && d.periapsis < 70000, severity: 'critical' },
    { id: 'max_q',    label: 'MAX-Q ZONE',            check: d => d.q > 20,                                   severity: 'warning'  },
];
```

- Evaluate all alerts on each `fetchTelemetry` call.
- Maintain an `activeAlerts = new Set()` of currently firing alert IDs.
- Render a fixed-position alert bar below the header that lists active alert badges.
- Use `AudioContext` to generate a short beep on alert transition from inactive → active.
- Style: `severity: 'critical'` → red; `severity: 'warning'` → amber; both should pulse with a CSS animation.

---

### FEATURE-04 · WebSocket Push Telemetry

**Description:** Replace HTTP polling with a WebSocket connection that pushes data only when the telemetry file changes.

**Implementation spec (server — `server.js`):**

```js
const { WebSocketServer } = require('ws');
const wss = new WebSocketServer({ server: app.listen(PORT, ...) });

fs.watch(path.join(__dirname, '..', 'telemetry', 'telemetry.json'), () => {
    const data = JSON.parse(fs.readFileSync(...));
    wss.clients.forEach(client => {
        if (client.readyState === 1) client.send(JSON.stringify(data));
    });
});
```

**Implementation spec (client — `telemetry_dashboard.html`):**

```js
function connectWS() {
    const ws = new WebSocket(`ws://${location.host}`);
    ws.onmessage = e => { processTelemData(JSON.parse(e.data)); };
    ws.onclose   = () => setTimeout(connectWS, 2000); // auto-reconnect
    ws.onerror   = () => ws.close();
}
connectWS();
```

Extract the body of `fetchTelemetry` into `processTelemData(data)` that both the WS handler and a fallback poll can call. Keep the HTTP polling route for environments where WS is unavailable; fall back automatically if the WebSocket connect fails after 3 retries.

---

### FEATURE-05 · Deployables Status Panel

**Description:** A panel in the right sidebar (below Resources) showing the deploy/jettison state of fairings and science instruments, driven by `deployables_cache.json`.

**Data source:** `deployables_cache.json` (requires BUG-11 fix first).

**Implementation spec:**

- Parse the kOS Lexicon flat-list format: iterate `entries` in pairs, where `entries[i]` is the key and `entries[i+1]` is the value (or sub-list).
- Build a lookup: `{ fairings: [{uid, module}, ...], deployables: [{uid, module}, ...] }`.
- Cross-reference UIDs against `activePartsCache` to determine staged/lost state.
- Cross-reference against `vessel_structure.parts` to resolve display names.
- Render two sub-sections: **Fairings** (jettisoned = strikethrough + muted) and **Deployables** (deployed = green tick, retracted = grey dash, staged/lost = muted strikethrough).
- Update on every `fetchTelemetry` by diffing against previous `activePartsCache`.

---

### FEATURE-06 · Telemetry Data Export (CSV)

**Description:** A button that serialises all in-memory chart data to a CSV file and triggers a browser download.

**Implementation spec:**

Add an export button to the graph drawer toggle bar (right side):

```html
<button onclick="exportCSV()" class="hud-btn" style="margin-left:auto;">⬇ Export CSV</button>
```

```js
function exportCSV() {
    const rows = [['timestamp_ms', 'altitude_km', 'velocity', 'twr', 'q_kpa']];
    const baseSeries = telemetryChart.data.datasets[0].data; // altitude as time anchor
    baseSeries.forEach((pt, i) => {
        rows.push([
            pt.x,
            telemetryChart.data.datasets[0].data[i]?.y ?? '',
            telemetryChart.data.datasets[1].data[i]?.y ?? '',
            telemetryChart.data.datasets[2].data[i]?.y ?? '',
            telemetryChart.data.datasets[3].data[i]?.y ?? '',
        ]);
    });
    const csv = rows.map(r => r.join(',')).join('\n');
    const a = document.createElement('a');
    a.href = URL.createObjectURL(new Blob([csv], { type: 'text/csv' }));
    a.download = `telemetry_${Date.now()}.csv`;
    a.click();
}
```

---

### FEATURE-07 · Blueprint Part Category Filter

**Description:** A row of toggle chips above the vessel viewer (visible only in Blueprint mode) that dim non-matching part categories.

**Implementation spec:**

- Define `PART_CATEGORIES` matching the categories already returned by `getPartCategory()`.
- Add a `Set<string> activeCategories` initialised to all categories (all on).
- Render chip buttons in the `.hud-controls` bar, visible only when `viewerMode === 'blueprint'`.
- In `drawProceduralPart` and `drawMeshPart`, check if the part's category is in `activeCategories`; if not, set `ctx.globalAlpha = 0.08` before drawing and restore after.
- Chips should use the same `.hud-btn` / `.hud-btn.active` styles already defined in the CSS.

---

### FEATURE-08 · Periapsis-in-Atmosphere Warning (Orbital Panel)

**Description:** A persistent inline warning in the Orbital panel when `periapsis` is below the current body's atmosphere ceiling.

**Data available:** `periapsis`, `body`.

**Implementation spec:**

Add a `BODY_ATM_LIMITS` constant:

```js
const BODY_ATM_LIMITS = { Kerbin: 70000, Duna: 50000, Eve: 90000, Jool: 200000, Laythe: 50000 };
```

In `updateHUD`, after setting the `peri` element:

```js
const atmLimit = BODY_ATM_LIMITS[d.body];
const periEl = document.getElementById('peri');
const warnEl = document.getElementById('atmo-warn'); // add this span to the HTML
if (atmLimit && d.periapsis < atmLimit) {
    periEl.style.color = 'var(--danger)';
    warnEl.textContent = '⚠ IN ATMO';
    warnEl.style.display = 'inline';
} else {
    periEl.style.color = '';
    warnEl.style.display = 'none';
}
```

Add to `telemetry_dashboard.html` inside the Orbital panel, after the periapsis row:

```html
<span id="atmo-warn" style="display:none; font-size:0.7rem; color:var(--danger); font-weight:700; letter-spacing:1px;"></span>
```

---

## Part 3 — Implementation Order (Suggested)

| Priority | ID | Effort | Dependency |
|----------|----|--------|------------|
| 1 | BUG-01 | 2 min | none |
| 2 | BUG-09 | 1 min | none |
| 3 | BUG-02 | 15 min | none |
| 4 | BUG-05 | 10 min | none |
| 5 | BUG-03 | 2 min | none |
| 6 | BUG-04 | 10 min | none |
| 7 | BUG-06 | 10 min | none |
| 8 | BUG-07 | 5 min | none |
| 9 | BUG-08 | 30 min | kOS script change + server.js |
| 10 | BUG-10 | 1 hr | `mu_mesh_export.py` + re-run export |
| 11 | BUG-11 | 30 min | server.js + kOS script copy path |
| 12 | FEATURE-08 | 20 min | none |
| 13 | FEATURE-02 | 45 min | none |
| 14 | FEATURE-03 | 1 hr | none |
| 15 | FEATURE-07 | 1 hr | none |
| 16 | FEATURE-06 | 30 min | none |
| 17 | FEATURE-05 | 2 hr | BUG-11 |
| 18 | FEATURE-01 | 3 hr | none |
| 19 | FEATURE-04 | 3 hr | BUG-06 (chained setTimeout first) |
