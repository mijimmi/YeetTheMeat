// === CHECK CONTROLLER CONNECTIONS ===
// Only P1 requires a controller - P2 can use keyboard as fallback
var p1_now_connected = gamepad_is_connected(0);

// Check if P1 disconnected (was connected, now isn't)
if (p1_connected && !p1_now_connected) {
    p1_disconnected = true;
}
// Check if P1 reconnected
if (p1_disconnected && p1_now_connected) {
    p1_disconnected = false;
}

// Update connection state
p1_connected = p1_now_connected;

// Set global pause only if P1 controller is disconnected
// P2 is always fine since they can use keyboard
global.controller_disconnected = p1_disconnected;

// Animation timer for pulsing effect
if (global.controller_disconnected) {
    disconnect_pulse_timer += 0.05;
}