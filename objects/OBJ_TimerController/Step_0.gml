// === PAUSE IF CONTROLLER DISCONNECTED OR GAME PAUSED ===
if (variable_global_exists("controller_disconnected") && global.controller_disconnected) {
    exit;
}

// Don't update timer when game is paused (e.g., recipe book open)
if (global.game_paused) {
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
        
        // Stop ALL music and sounds before playing complete sound
        audio_stop_all();
        
        // Play level complete sound
        audio_sound_gain(sfx_complete, 0.85, 0);
        audio_play_sound(sfx_complete, 1, false);
        
        // Show results screen
        if (instance_exists(OBJ_Scoring)) {
            OBJ_Scoring.show_results = true;
        }
    }
}