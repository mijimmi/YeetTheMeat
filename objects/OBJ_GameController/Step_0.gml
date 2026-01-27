// === CHECK CONTROLLER CONNECTIONS ===
var p1_now_connected = gamepad_is_connected(0);
var p2_now_connected = gamepad_is_connected(1);

// Check if P1 disconnected (was connected, now isn't)
if (p1_connected && !p1_now_connected) {
    p1_disconnected = true;
}
// Check if P1 reconnected
if (p1_disconnected && p1_now_connected) {
    p1_disconnected = false;
}

// Check if P2 disconnected (was connected, now isn't)
if (p2_connected && !p2_now_connected) {
    p2_disconnected = true;
}
// Check if P2 reconnected
if (p2_disconnected && p2_now_connected) {
    p2_disconnected = false;
}

// Update connection states
p1_connected = p1_now_connected;
p2_connected = p2_now_connected;

// Set global pause if either controller is disconnected
global.controller_disconnected = (p1_disconnected || p2_disconnected);

// Animation timer for pulsing effect
if (global.controller_disconnected) {
    disconnect_pulse_timer += 0.05;
}