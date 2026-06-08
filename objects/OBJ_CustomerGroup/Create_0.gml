// Group management object (invisible)
visible = false;

group_size     = 0;         // How many customers in this group (1-4)
customers      = [];        // Array of customer instances in this group
assigned_table = noone;     // Which table they're going to
group_state    = "walking"; // "walking", "seated", "waiting", "leaving"

// === SPAWN SIDE (set by spawner) ===
spawn_side = "left";  // "left" or "right" — set automatically by OBJ_CustomerSpawner
exit_x     = 80;      // Updated by spawner to match the spawn side
exit_y     = 500;     // Updated by spawner to match the spawn y