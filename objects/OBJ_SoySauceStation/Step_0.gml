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

// === POPCORN PARTICLES ===
for (var _i = ds_list_size(popcorn_particles) - 1; _i >= 0; _i--) {
    var _p = popcorn_particles[| _i];
    _p[0] += _p[2];
    _p[1] += _p[3];
    _p[3] += 0.28;
    _p[5] -= 0.025;
    if (_p[5] <= 0) ds_list_delete(popcorn_particles, _i);
}

if (is_processing) {
    popcorn_timer++;
    if (popcorn_timer >= popcorn_interval) {
        popcorn_timer = 0;
        popcorn_interval = irandom_range(35, 60);
        var _cloud_sprites = [spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4];
        var _sauce_tint = make_color_rgb(180, 140, 100); // brownish tint for soy sauce pops
        var _spawn = irandom_range(1, 3);
        for (var _s = 0; _s < _spawn; _s++) {
            var _px  = x + food_offset_x + random_range(-8, 8);
            var _py  = y + food_offset_y + random_range(-4, 4);
            var _pvx = random_range(-2.2, 2.2);
            var _pvy = random_range(-4.5, -2.5);
            var _psc = random_range(0.55, 1.0);
            var _pal = random_range(0.75, 1.0);
            var _spr = _cloud_sprites[irandom(3)];
            ds_list_add(popcorn_particles, [_px, _py, _pvx, _pvy, 0, _pal, _spr, _psc]);
        }
    }
} else {
    popcorn_timer = 0;
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
