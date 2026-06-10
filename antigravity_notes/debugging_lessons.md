# KerboScript Debugging Lessons & Constraints

Through the implementation and iterative testing of the Minmus probe mission, we have cataloged several critical rules and behaviors of the kOS compiler and runtime environment.

## 1. String Literals & Escaping
*   **Single Quotes Forbidden:** kOS does **not** support single quotes (`'`) for defining strings or character literals. All strings must be double-quoted.
*   **No Backslash Escaping:** The backslash character (`\`) is treated as a regular literal character in kOS, not an escape prefix. Consequently, `\"` is parsed as a backslash followed by a closing double quote, which terminates the string early and leads to parser crashes (e.g. `Unexpected token 'n'`).
*   **The Double-Quote Solution:**
    *   To represent a double-quote character inside a double-quoted string, you must double it: `"This is a ""double-quoted"" word."`.
    *   Alternatively, declare a helper variable containing `char(34)` (the ASCII code for a double-quote):
        ```kerboscript
        local q is char(34).
        local json is "{" + q + "key" + q + ":" + q + "value" + q + "}".
        ```
        This completely eliminates string-escaping bugs when constructing JSON formats.

## 2. Variable Scope & `@lazyGlobal off`
*   With `@lazyGlobal off` active at the top of a file, kOS requires all variables to be explicitly declared.
*   **`list` Command Scope:** The built-in list commands (e.g. `list resources in resList`) do **not** automatically declare the target variable. You must declare the list variable beforehand:
    ```kerboscript
    local resList is list().
    list resources in resList.
    ```
*   **Reserved Keyword Conflicts:** Naming a local variable after a built-in kOS structure or function (e.g., `local processor is core...`) will trigger a compiler error: `Not allowed to SET a name that will clobber or hide the BUILDIN_FUNCTION called '...'`. Avoid naming variables `processor`, `target`, `body`, `q`, `mod`, `logfile`, etc. (where `q` represents dynamic pressure, `mod` represents the modulo operator, and `logfile` is a reserved bound file logger keyword).
*   **`throttle` and `steering` System Locks:** `throttle` and `steering` are special system variables that can only be controlled via the `lock` statement (e.g., `lock throttle to 1.`). Attempting to write `set throttle to ...` or `set steering to ...` under `@lazyGlobal off` causes the compiler to interpret it as an implicit variable definition, which clobbers the reserved system locks and crashes compilation. Always use `lock`.
*   **File-Scope Compiler Directives:** If you must compile legacy/external libraries that contain undeclared variables within a project using `@lazyGlobal off`, prepend `@lazyGlobal on.` to the top of those specific library files. Because `@lazyGlobal` is file-scoped, this allows those libraries to compile with lazy variables enabled without clobbering your project-wide strict settings.
*   **No Inline Conditionals (Ternary expressions):** kOS does not support inline conditional expressions like `(if condition { trueVal } else { falseVal })`. `if` is strictly a block statement. Any conditional logic must be evaluated and stored in a variable prior to use in string composition or function calls:
    ```kerboscript
    local result is "false".
    if condition { set result to "true". }
    ```

## 3. Unity & kOS Log Monitoring
*   kOS prints all output (including runtime errors, stack traces, and `print` statements) to the standard Unity `KSP.log` file in the game's root directory:
    `C:\Program Files (x86)\Steam\steamapps\common\Kerbal Space Program\KSP.log`
*   We can easily debug by filtering for entries containing `[LOG ...]` or `kOS`.

## 4. Common Reserved kOS Built-ins
When declaring local or global variables under `@lazyGlobal off`, avoid using names that clobber built-in mathematical functions, constants, structures, or bound variables.

### Mathematical Functions
*   `abs`, `ceiling`, `floor`, `round`, `sqrt`
*   `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `atan2`
*   `min`, `max`, `mod`, `ln`, `log10`

### Vector & Rotation Creators
*   `v` (represents vector creator `v(x,y,z)`)
*   `r` (represents rotation creator `r(p,y,r)`)
*   `q` (represents quaternion creator `q(x,y,z,w)` or dynamic pressure `ship:q`)
*   `heading`, `latlng`

### Suffixes & Vessel/Orbit Bounds
*   `ship`, `target`, `body`, `sun`
*   `core`, `processor`, `terminal`
*   `node`, `list`, `time`, `eta`
*   `warp`, `warpmode`, `config`

### Boolean & Special Values
*   `true`, `false`, `none`

## 5. kOS Triggers & Cleanup (Race Conditions & Double Staging)
*   **Global Triggers Persist:** In kOS, `when ... then` triggers are globally registered inside the CPU execution queue. If a sub-script (e.g., `CircToAp.ks` or `ExeNode.ks`) defines a trigger like `when running = true then` or `when maxthrust < InitialStageThrust then` and preserves it (`preserve.`), this trigger remains registered in the CPU *even after the script finishes executing*!
*   **Trigger Interference & Flickering:** If another script later runs and sets the same global variable (like `running` or `InitialStageThrust`) to `true`, the old trigger will reactivate. This causes multiple print loops or staging commands to execute concurrently on the same tick, resulting in terminal flickering and double-staging (which can discard your active engines/stages prematurely and lead to loss of vessel).
*   **Self-Cleaning Trigger Pattern:** To prevent this, triggers must be designed to automatically delete themselves when their active context terminates. Since a trigger is removed from the queue if its body executes and does *not* call `preserve.`, we can write self-cleaning triggers using the following pattern:
    ```kerboscript
    when true then {
        if not running {
            // Do NOT call preserve. Trigger gets deleted!
        } else if trigger_condition {
            // Execute logic
            preserve.
        } else {
            preserve.
        }
    }
    ```
    On the very next physics tick after the script sets `running` to `false`, the trigger evaluates to true, enters the `if not running` block, skips `preserve.`, and is permanently purged from the queue.

## 6. Celestial Parameters & Wiki Verification
*   **Wiki Reference:** When designing orbital transfers, captures, and inclinations for other planets or moons, always check the KSP Wiki for precise physical and orbital constants (radius, gravitational parameter $\mu$, orbital period, maximum mountain height, and sphere of influence).
*   **Minmus Reference:** For Minmus, $\mu = 1.7658000 \times 10^9 \text{ m}^3/\text{s}^2$, radius = $60 \text{ km}$, and the highest peaks are over **$5.7 \text{ km}$**. Any orbit below $6 \text{ km}$ will collide with the terrain. Reference [ksp_wiki_minmus.md](file:///c:/Program%20Files%20%28x86%29/Steam/steamapps/common/Kerbal%20Space%20Program/Ships/Script/gemini_notes/ksp_wiki_minmus.md) for details.
