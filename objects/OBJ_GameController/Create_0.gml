// Global pause state
global.game_paused = false;

// Input buffer to prevent instant unpause
pause_buffer = 0;

// Font
global.game_font = fnt_winkle;

// === CONTROLLER DISCONNECT TRACKING ===
p1_connected = gamepad_is_connected(0);
p2_connected = gamepad_is_connected(1);
p1_disconnected = false;
p2_disconnected = false;
global.controller_disconnected = false;

// Animation for disconnect message
disconnect_pulse_timer = 0;