# KerboScript Coding Style Guide

Based on an analysis of the existing `.ks` files in this project (e.g., `KOSmodore/main.ks`, `SpaceCore/Launch.ks`, `boot/KOSHUD.ks`, `DASA/probe.ks`), the following conventions should be observed when writing or modifying KerboScript files.

## 1. General Formatting and Syntax
*   **Statement Termination:** All statements MUST end with a period (`.`). This is a strict requirement of the language.
*   **Case Sensitivity:** While KerboScript is intrinsically case-insensitive, the project exhibits a mix of styles.
    *   **Modern/Complex Scripts (e.g., `main.ks`, `KOSHUD.ks`):** Prefer lowercase for keywords (`if`, `for`, `set`, `global`, `local`, `function`).
    *   **Simple/Legacy Scripts (e.g., `probe.ks`):** Sometimes use ALL CAPS for keywords (`PRINT`, `WAIT`, `SET`).
    *   **Recommendation:** Stick to lowercase for language keywords and built-in functions to maintain readability in more complex logic.
*   **Indentation:** Use tabs or spaces consistently to denote code blocks. The codebase predominantly uses tabs or 2/4 spaces depending on the author. When editing an existing file, strictly follow its current indentation style.

## 2. Variables and Scope
*   **Global Directives:** Use `@lazyGlobal off.` at the top of complex scripts to enforce explicit variable declarations.
*   **Declaration:** Always declare variables explicitly using `local` or `global` (or `set` for reassignment) if `@lazyGlobal off` is used.
    *   `local myVar is 0.`
    *   `global myVar is 0.`
*   **Parameters:** Use `declare parameter param1, param2 is default_val.` at the very beginning of the file if the script expects arguments.
*   **Naming Conventions:** Variable names generally use camelCase (`wantedAngle`), PascalCase (`LoadedTrack`), or occasionally snake_case (`wanted_throttle`). Choose one that aligns with the surrounding code.

## 3. Functions
*   **Declaration:**
    ```kerboscript
    function MyFunction {
        parameter arg1. // Optional parameters
        // logic
    }
    ```
*   **Naming:** Use PascalCase or camelCase for function names (e.g., `ExitOS`, `InitTerminalMAIN`, `goroverpos`).
*   **Braces:** Place the opening brace `{` on the same line as the function declaration.

## 4. Control Structures
*   **If/Else:**
    *   Opening brace on the same line.
    *   `else` on the same line as the closing brace, or on the next line.
    ```kerboscript
    if condition {
        // logic
    } else {
        // alternative logic
    }
    ```
    *   **Single-line statements:** Curly braces can be omitted for single-line blocks, but ensure the period is correctly placed: `if condition set x to 1.`
*   **Loops:**
    *   `UNTIL condition { ... }`
    *   `FOR item IN list { ... }`
    *   `FROM {local x is 0.} UNTIL x = 10 STEP {set x to x+1.} DO { ... }`

## 5. Comments and Documentation
*   **Inline Comments:** Use `//` for single-line comments.
*   **Headers:** Use decorative headers for major files (e.g., box-like structures with `//` and `|` or `-`).
*   **Regions:** For very large files (like `KOSHUD.ks`), use `//#region Region Name` and `//#endregion` to allow text editors to fold code blocks.

## 6. File Management
*   **Loading Scripts:**
    *   Use `run once "path/to/script.ks".` to load dependencies.
    *   Alternatively, use `runpath("0:/path/script", args...).`
*   **Paths:** Use absolute paths starting from the root (e.g., `"0:/..."` or just `"/..."`) when referencing files across directories to avoid relative path confusion.

## Summary
When writing KerboScript for this project, prioritize readability and scope safety. Explicitly declare variables (`local`/`global`), terminate lines with `.`, and adapt your casing (keywords vs. variables) to seamlessly blend with the specific file you are modifying.
