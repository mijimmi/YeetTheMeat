event_inherited();

// === PROGRESS LOGIC ===
if (is_processing && active_player != noone) {
    // Check if player is still in range and not moving
    var player = active_player;
    
    if (!instance_exists(player)) {
        // Player destroyed, cancel
        cancel_processing();
    }
    else {
        var dist = point_distance(x, y, player.x, player.y);
        var player_speed = point_distance(0, 0, player.velocity_x, player.velocity_y);
        
        // Grace period: don't check speed for first 10 frames (player might still be moving when placing)
        var grace_period = 10;
        
        // Interrupt if player moved away, or moving too fast (after grace period)
        if (dist > interact_range || (progress_current > grace_period && player_speed > 2)) {
            cancel_processing();
        }
        else {
            // Progress!
            progress_current++;
            
            // Play saucing sound when starting
            if (progress_current == 1) {
                audio_sound_gain(sfx_saucing, 0.45, 0);
                audio_play_sound(sfx_saucing, 1, false);
            }
            
            if (progress_current >= progress_max) {
                // Complete the saucing!
                complete_saucing();
            }
        }
    }
}

function cancel_processing() {
    is_processing = false;
    progress_current = 0;
    active_player = noone;
    // Stop saucing sound if it was playing
    audio_stop_sound(sfx_saucing);
    // Item stays on station but not processed
}

function complete_saucing() {
    if (item_being_processed != noone && instance_exists(item_being_processed)) {
        // Transform the item to soy_sliced
        item_being_processed.food_type = "soy_sliced";
    }
    
    // Stop saucing sound
    audio_stop_sound(sfx_saucing);
    
    is_processing = false;
    progress_current = 0;
    active_player = noone;
    item_being_processed = noone;
}
