spawn_timer++;

// Check if it's time to spawn
if (spawn_timer >= next_spawn_time && can_spawn) {
    attempt_spawn_group();
    
    // Reset timer and set next spawn time
    spawn_timer = 0;
    next_spawn_time = irandom_range(spawn_delay_min, spawn_delay_max);
}

// Clean up finished groups
for (var i = array_length(active_groups) - 1; i >= 0; i--) {
    var grp = active_groups[i];
    if (!instance_exists(grp)) {
        array_delete(active_groups, i, 1);
    }
}