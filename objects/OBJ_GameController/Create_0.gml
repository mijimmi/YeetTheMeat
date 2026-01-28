// === GAME MODE (set by menu, default to multiplayer for testing) ===
if (!variable_global_exists("game_mode")) {
    global.game_mode = "multiplayer";
}

// Global pause state
global.game_paused = false;

// Input buffer to prevent instant unpause
pause_buffer = 0;

// Font
global.game_font = fnt_winkle;

// === CONTROLLER DISCONNECT TRACKING ===
// P1 requires a controller, P2 can use keyboard as fallback
p1_connected = gamepad_is_connected(0);
p1_disconnected = false;
global.controller_disconnected = false;

// Animation for disconnect message
disconnect_pulse_timer = 0;