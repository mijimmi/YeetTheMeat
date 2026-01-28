// === PAUSE IF CONTROLLER DISCONNECTED ===
if (variable_global_exists("controller_disconnected") && global.controller_disconnected) {
    exit;
}

// === TIMER COUNTDOWN ===
if (timer_active && game_timer > 0) {
    game_timer--;
    
    // Check if time ran out
    if (game_timer <= 0) {
        game_timer = 0;
        game_finished = true;
        timer_active = false;
        
        // Show results screen
        if (instance_exists(OBJ_Scoring)) {
            OBJ_Scoring.show_results = true;
        }
    }
}