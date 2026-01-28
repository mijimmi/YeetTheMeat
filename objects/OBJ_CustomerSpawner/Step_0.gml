// Don't spawn customers when game is paused (e.g., recipe book open)
if (global.game_paused) {
    exit;
}

spawn_timer++;
game_timer++;

// === DIFFICULTY RAMPING ===
// Calculate progress (0 to 1) based on how much time has passed
var ramp_progress = clamp(game_timer / ramp_duration, 0, 1);

// Smoothly interpolate spawn delays from slow (start) to fast (target)
// Using lerp: starts at spawn_delay_min, ends at spawn_delay_min_target
var current_delay_min = lerp(spawn_delay_min, spawn_delay_min_target, ramp_progress);
var current_delay_max = lerp(spawn_delay_max, spawn_delay_max_target, ramp_progress);

// Check if it's time to spawn
if (spawn_timer >= next_spawn_time && can_spawn) {
    attempt_spawn_group();
    
    // Reset timer and set next spawn time using current difficulty
    spawn_timer = 0;
    next_spawn_time = irandom_range(current_delay_min, current_delay_max);
}

// Clean up finished groups
for (var i = array_length(active_groups) - 1; i >= 0; i--) {
    var grp = active_groups[i];
    if (!instance_exists(grp)) {
        array_delete(active_groups, i, 1);
    }
}