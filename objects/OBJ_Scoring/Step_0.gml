// Step Event - OBJ_Scoring

// When showing results, pause the game
if (show_results) {
    // Stop all customer movement
    with (OBJ_Customer) {
        customer_state = "idle";
    }
    
    // Stop spawning
    with (OBJ_CustomerSpawner) {
        can_spawn = false;
    }
}