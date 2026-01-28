// === TIMER CONTROLLER ===

// Timer settings
game_timer = 14400;  // 4:00 at 60fps (240 seconds * 60)
timer_max = 14400;

// Visual settings
timer_bar_width = 30;
timer_bar_height = 220;
timer_margin_x = 40;  // Distance from left edge

// Game state
timer_active = false;  // Set to true when tutorial ends
game_finished = false;

// Call this function to start the timer (e.g., after tutorial)
function start_timer() {
    timer_active = true;
}

// Call this function to pause the timer
function pause_timer() {
    timer_active = false;
}

// Call this function to reset the timer
function reset_timer() {
    game_timer = timer_max;
    game_finished = false;
}

// Call this to check if time ran out
function is_time_up() {
    return game_timer <= 0;
}

// Get remaining time in seconds
function get_time_remaining() {
    return floor(game_timer / 60);
}
