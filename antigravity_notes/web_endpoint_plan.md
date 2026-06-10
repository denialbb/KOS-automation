# Real-time Telemetry Web Endpoint Plan

To monitor the Minmus mission in real-time outside of KSP, we will build a local web server that reads telemetry output from the probe and displays it on a browser interface.

## 1. kOS Telemetry Export
The mission script will periodically write critical telemetry data to a local file in the `0:` archive (which maps to the local machine's `Ships/Script` folder).
- **File:** `telemetry.json`
- **Data Logged:**
  - Vessel Name & Status
  - Mission Stage (e.g., "Pre-Launch", "Ascent", "Coasting", "Capture")
  - Altitude, Orbit Parameters (Pe, Ap, Inc)
  - Resources (Electric Charge, Fuel)
  - Delta-V Budget
  - Time to next maneuver node

## 2. Web Server (Node.js)
A lightweight Node.js server will be created in the `Ships/Script/telemetry_server` folder.
- **Backend:** Express.js will serve the static files and provide a JSON endpoint (`/api/telemetry`) that reads `telemetry.json` from the root script folder.
- **Frontend:** A sleek, dark-themed dashboard using HTML/CSS/JS that fetches data from the API every second and displays it.
- **Aesthetics:** The UI will feature a rich, modern design with dynamic status indicators (e.g., green for normal power, red for critical APU usage), micro-animations for data updates, and a progress bar for Delta-V.

## 3. Workflow
- kOS script writes to `telemetry.json` every second.
- The Node.js app reads the file when the browser requests it.
- The frontend dashboard updates seamlessly, giving the user a "Mission Control" feel on their second monitor.
