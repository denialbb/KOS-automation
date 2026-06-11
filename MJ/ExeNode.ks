@lazyGlobal on.

if not hasnode {
    print "ExeNode: No maneuver node present. Aborting.".
    if defined logMsg { logMsg("ExeNode called with no active maneuver node. Skipping."). }
    abort.
}

set nd to nextnode.

clearscreen.
set running to true.
when true then {
    if not running {
        // cleanup
    } else {
        print "--- MANEUVER NODE INFO ---" at (0,2).
        print "Total maneuver delta-V: "+ round(nd:deltav:mag,1)+" m/s       " at (0,3).
        local tLeft is max(0, nd:eta).
        local h is floor(tLeft / 3600).
        local m is floor(mod(tLeft, 3600) / 60).
        local s is floor(mod(tLeft, 60)).
        local hStr is "" + h. if h < 10 { set hStr to "0" + h. }
        local mStr is "" + m. if m < 10 { set mStr to "0" + m. }
        local sStr is "" + s. if s < 10 { set sStr to "0" + s. }
        print "Time to maneuver: T- " + hStr + ":" + mStr + ":" + sStr + "       " at (0,4).
        print "Remaining delta-V: "+round(nd:deltav:mag,1)+" m/s       " at (0,5).
        preserve.
    }
}

// Release kOS steering/throttle to prepare for autopilot handoff
unlock steering.
unlock throttle.
set ship:control:pilotmainthrottle to 0.

// Suffix checking for MechJeb executor
local hasMjNode is false.
local mjNodeSuffix is "".

if addons:available("MJ") {
    if addons:mj:hassuffix("NODE") {
        set hasMjNode to true.
        set mjNodeSuffix to "NODE".
    } else if addons:mj:hassuffix("NODEEXECUTOR") {
        set hasMjNode to true.
        set mjNodeSuffix to "NODEEXECUTOR".
    } else if addons:mj:hassuffix("EXECUTE") {
        set hasMjNode to true.
        set mjNodeSuffix to "EXECUTE".
    }
}

if hasMjNode {
    print "[MJ] Engaging MechJeb Node Executor...".
    if mjNodeSuffix = "NODE" {
        set addons:mj:node:enabled to true.
    } else if mjNodeSuffix = "NODEEXECUTOR" {
        set addons:mj:nodeexecutor:enabled to true.
    } else if mjNodeSuffix = "EXECUTE" {
        if addons:mj:execute:hassuffix("ENABLED") {
            set addons:mj:execute:enabled to true.
        } else if addons:mj:execute:hassuffix("EXECUTE_ALL_NODES") {
            set addons:mj:execute:execute_all_nodes to true.
        }
    }

    wait until not hasnode.

    print "[MJ] Node execution complete.".
    if mjNodeSuffix = "NODE" {
        set addons:mj:node:enabled to false.
    } else if mjNodeSuffix = "NODEEXECUTOR" {
        set addons:mj:nodeexecutor:enabled to false.
    } else if mjNodeSuffix = "EXECUTE" {
        if addons:mj:execute:hassuffix("ENABLED") {
            set addons:mj:execute:enabled to false.
        } else if addons:mj:execute:hassuffix("EXECUTE_ALL_NODES") {
            set addons:mj:execute:execute_all_nodes to false.
        }
    }
} else {
    print "[ExeNode] Falling back to native kOS maneuver node execution.".
    
    local max_acc is 0.
    if ship:mass > 0 { set max_acc to ship:availablethrust / ship:mass. }
    if max_acc = 0 {
        print "WARNING: No thrust available. Waiting for active engine...".
        wait until ship:availablethrust > 0.
        set max_acc to ship:availablethrust / ship:mass.
    }

    // Estimate Isp for exhaust velocity (ve) to get precise burn time
    local effIsp is 0.
    local totalThrust is 0.
    local totalFlow is 0.
    list engines in engList.
    for eng in engList {
        if eng:ignited and eng:isp > 0 {
            set totalThrust to totalThrust + eng:availablethrust.
            set totalFlow to totalFlow + (eng:availablethrust / (eng:isp * 9.80665)).
        }
    }
    if totalFlow > 0 {
        set effIsp to totalThrust / (totalFlow * 9.80665).
    } else {
        for eng in engList {
            if eng:isp > 0 {
                set effIsp to eng:isp.
                break.
            }
        }
        if effIsp = 0 {
            set effIsp to 300. // fallback
        }
    }
    
    local g0 is 9.80665.
    local ve is effIsp * g0.
    local dv is nd:deltav:mag.
    local burn_time is (dv * ship:mass / max(1, ship:availablethrust)) * (1 - dv / (2 * ve)).
    print "[ExeNode] Estimated burn duration: " + round(burn_time, 2) + "s".

    // Orient ship to burn direction
    local burn_dir is nd:deltav.
    lock steering to burn_dir.

    // Warp to the burn start time if eta is long
    local burnStartEta is nd:eta - burn_time / 2.
    if burnStartEta > 40 {
        print "[ExeNode] Warping to burn window...".
        set warpmode to "rails".
        warpto(time:seconds + burnStartEta - 30).
        wait until nd:eta - burn_time / 2 <= 35.
    }

    print "[ExeNode] Aligning vessel...".
    wait until vang(ship:facing:forevector, nd:deltav) < 1.5 and nd:eta <= burn_time / 2.

    print "[ExeNode] Beginning burn...".
    local tVal is 0.
    lock throttle to tVal.
    local initial_dv is nd:deltav.
    local done is false.

    until done {
        // Handle staging during burn
        if ship:availablethrust < 0.1 {
            stage.
            wait 0.5.
        }

        local rem_dv is nd:deltav:mag.
        local cur_acc is 0.
        if ship:mass > 0 { set cur_acc to ship:availablethrust / ship:mass. }

        // Freeze steering vector when delta-V is very low to prevent spin
        if rem_dv > 1.0 {
            set burn_dir to nd:deltav.
        }

        // Precision throttle control
        if rem_dv < 0.15 or vdot(initial_dv, nd:deltav) < 0 {
            set done to true.
        } else {
            if cur_acc > 0 {
                set tVal to min(1, rem_dv / cur_acc).
            } else {
                set tVal to 1.
            }
        }
        wait 0.
    }

    lock throttle to 0.
    unlock throttle.
    unlock steering.
    print "[ExeNode] Burn complete. Removing node.".
    remove nd.
    wait 0.1.
}

set running to false.
sas on.
clearscreen.