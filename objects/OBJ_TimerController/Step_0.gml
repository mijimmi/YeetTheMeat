// === TIMER COUNTDOWN ===
if (timer_active && game_timer > 0) {
    game_timer--;
    
    // Check if time ran out
    if (game_timer <= 0) {
        game_timer = 0;
        game_finished = true;
        timer_active = false;
        
        // TODO: Trigger game over / results screen
        // You can add your game end logic here
    }
}
