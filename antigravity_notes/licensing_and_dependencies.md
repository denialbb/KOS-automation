# Project Licensing and Dependency Audit

This document details the licensing status of our current codebase, identifies conflicts, and outlines the options for ensuring compliance when hosting the project on GitHub.

## 1. Inventory of Current Dependencies

1. **Express.js** (`telemetry_server/package.json`)
   - **License:** MIT
   - **Type:** Permissive
   - **Status:** Compliant. Compatible with both MIT and GPL.

2. **SpaceCore** (`SpaceCore/`)
   - **License:** MIT (Copyright (c) 2020 bodryxon)
   - **Type:** Permissive
   - **Status:** Compliant. Compatible with both MIT and GPL.

3. **io_object_mu** (`telemetry_server/io_object_mu/`)
   - **License:** GNU GPL v2
   - **Type:** Strong Copyleft
   - **Status:** **Incompatible** with distributing the parent repository under the MIT license.

---

## 2. The Legal Mechanics of the GPL v2 Conflict

The GNU General Public License v2 (GPLv2) is a strong copyleft license. The core mechanism is defined in Section 2(b):
> *"You must cause any work that you distribute or publish, that in whole or in part contains or is derived from the Program or any part thereof, to be licensed as a whole at no charge to all third parties under the terms of this License."*

### Why the current setup violates this:
- We are bundling the entire source code of `io_object_mu` directly inside our project repository (in the `telemetry_server/io_object_mu` directory).
- If the project is published on GitHub under the MIT license, we are distributing a combined work containing a GPL v2 component under a non-GPL license. This is a license violation.

---

## 3. Options for Compliance

### Option A: Re-license the Repository under GPL v2 (or GPL v3)
- **Concept:** Adopt a copyleft license for the entire repository to match the `io_object_mu` dependency.
- **Pros:** Easiest option; requires no code changes. Users get the mesh exporter ready-to-use out of the box.
- **Cons:** Restricts downstream commercial or closed-source reuse of the autopilot scripts.

### Option B: Keep the MIT License and Externalize the GPL Dependency
- **Concept:** Remove the `io_object_mu` folder from git history and `.gitignore` it. Add download logic to the launcher (`launch_dashboard.py`) to download the library directly from its source repository to the user's local directory at run/install time.
- **Pros:** Your original codebase remains 100% MIT licensed. No GPL obligations are triggered because you are not *distributing* the GPL code; the user compiles/combines it privately on their own machine.
- **Cons:** Requires adding file downloading and extraction logic to your python scripts, introducing potential point of failures if the source repository becomes unavailable.
