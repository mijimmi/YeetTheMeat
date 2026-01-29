// Step Event - OBJ_Scoring

// Animate score pulse
score_pulse += 0.1;

// Smoothly animate scale back to 1
if (score_scale > 1) {
    score_scale = lerp(score_scale, 1, 0.15);
}

// When showing results, pause the game
if (show_results) {
    // Pause the game globally
    global.game_paused = true;
    
    // Stop all customer movement
    with (OBJ_Customer) {
        customer_state = "idle";
    }
    
    // Stop spawning
    with (OBJ_CustomerSpawner) {
        can_spawn = false;
    }
}