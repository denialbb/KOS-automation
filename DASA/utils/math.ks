@LAZYGLOBAL OFF.

GLOBAL FUNCTION clamp {
    PARAMETER val, mn, mx.
    IF val < mn RETURN mn.
    IF val > mx RETURN mx.
    RETURN val.
}

GLOBAL FUNCTION createNodeFromVector {
    PARAMETER burnTime, dVVector.
    LOCAL r_at IS positionat(SHIP, burnTime) - positionat(SHIP:BODY, burnTime).
    LOCAL v_at IS velocityat(SHIP, burnTime):ORBIT.

    LOCAL pro_dir IS v_at:normalized.
    LOCAL norm_dir IS VCRS(v_at, r_at):normalized.
    LOCAL rad_dir IS VCRS(pro_dir, norm_dir):normalized.

    LOCAL dV_pro IS VDOT(dVVector, pro_dir).
    LOCAL dV_norm IS VDOT(dVVector, norm_dir).
    LOCAL dV_rad IS VDOT(dVVector, rad_dir).

    LOCAL nd IS NODE(burnTime, dV_rad, dV_norm, dV_pro).
    ADD nd.
    RETURN nd.
}
