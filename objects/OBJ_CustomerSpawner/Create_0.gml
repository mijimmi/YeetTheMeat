// Check if this is tutorial room
if (room == tutorial_room) { 
    can_spawn = false; // Disable automatic spawning in tutorial
}

// === SPAWN POINTS (Left and Right sides) ===
spawn_left_x  = 80;
spawn_right_x = 1840;

spawn_left_exit_x  = 80;
spawn_right_exit_x = 1840;

// Y ranges — avoids spawning in the vertical middle of the 1920x1080 room
// TWEAK: adjust these to match where your room entrances actually are
spawn_y_top_min    = 100;
spawn_y_top_max    = 350;
spawn_y_bottom_min = 730;
spawn_y_bottom_max = 980;

// Legacy single values (kept so nothing else in your code breaks)
spawn_x = spawn_left_x;
spawn_y = 500;
exit_x  = spawn_left_exit_x;
exit_y  = 300;

// === TIMING ===
spawn_timer = 0;

// Start SLOW (20-30 seconds between spawns) to ease players in
spawn_delay_min = 20 * 60;   // 20 seconds initially
spawn_delay_max = 30 * 60;   // 30 seconds initially

// Ramp down to faster spawns (8-12 seconds) over time
spawn_delay_min_target = 8 * 60;
spawn_delay_max_target = 12 * 60;

// Difficulty ramping
game_timer    = 0;
ramp_duration = 180 * 60;

next_spawn_time = 0;

// === STATE ===
can_spawn = true;
active_groups = [];
first_customer_seated = false;
first_spawn_done = false;   // first group is capped at 1-2 customers

// === AVAILABLE DISHES (What customers can order) ===
// Format: [food_type, order_sprite, display_name]
available_orders = [
    // Easy dishes
    ["plated",  spr_ricedish,         "Rice"],
    ["plated",  spr_takoyakidish,     "Kwek-kwek"],
    ["gulaman", spr_gulaman,          "Gulaman"],
    ["buko",    spr_bukojuice,        "Buko Juice"],
    
    // Medium dishes
    ["plated",  spr_meatlumpiadish,   "Meat Lumpia"],
    ["plated",  spr_veggielumpiadish, "Veggie Lumpia"],
    ["plated",  spr_adobodish,        "Adobo"],
    ["plated",  spr_porkchopdish,     "Fried Pork"],
    
    // Hard dishes
    ["plated",  spr_calderetadish,    "Caldereta"]
];

// First group arrives quickly; later spawns use the slower ramp above
next_spawn_time = irandom_range(4 * 60, 7 * 60);  // ~4-7 seconds

function attempt_spawn_group() {
    var roll = irandom(99);
    var group_size;
    if (!first_spawn_done) {
        // Very first group only: solo or pair to ease players in
        group_size = (roll < 50) ? 1 : 2;
    } else if (roll < 40) {
        group_size = 1;      // 40% chance
    } else if (roll < 75) {
        group_size = 2;      // 35% chance
    } else if (roll < 90) {
        group_size = 3;      // 15% chance
    } else {
        group_size = 4;      // 10% chance
    }
    
    // Pick the closest free table and spawn from whichever entrance (left/right)
    // is nearest to that table.
    var pick = find_best_spawn_and_table(group_size);
    
    if (pick.table != noone) {
        spawn_customer_group(group_size, pick.table, pick.side, pick.spawn_x, pick.spawn_y);
        if (!first_spawn_done) first_spawn_done = true;
    } else {
        can_spawn = false;
        alarm[0] = 60;
    }
}

function find_best_spawn_and_table(group_size) {
    var all_tables = [OBJ_Table1, OBJ_Table2, OBJ_Table3, OBJ_Table4, OBJ_Table5, OBJ_Table6];
    var result = { table: noone, side: "left", spawn_x: spawn_left_x, spawn_y: 540 };
    var best_dist = infinity;

    for (var i = 0; i < array_length(all_tables); i++) {
        var tbl = instance_find(all_tables[i], 0);
        if (tbl == noone || tbl.is_occupied) continue;
        if (tbl.chair_count < group_size) continue;

        // Align spawn Y with the table so the walk-in feels natural
        var spawn_y = clamp(tbl.y, 360, 720);

        var d_left  = point_distance(spawn_left_x,  spawn_y, tbl.x, tbl.y);
        var d_right = point_distance(spawn_right_x, spawn_y, tbl.x, tbl.y);

        if (d_left < best_dist) {
            best_dist = d_left;
            result.table    = tbl;
            result.side     = "left";
            result.spawn_x  = spawn_left_x;
            result.spawn_y  = spawn_y;
        }
        if (d_right < best_dist) {
            best_dist = d_right;
            result.table    = tbl;
            result.side     = "right";
            result.spawn_x  = spawn_right_x;
            result.spawn_y  = spawn_y;
        }
    }

    return result;
}

function spawn_customer_group(group_size, target_table, spawn_side, group_spawn_x, group_spawn_y) {
    if (target_table == noone || !instance_exists(target_table)) {
        show_debug_message("ERROR: Invalid table passed to spawn_customer_group!");
        can_spawn = true;
        return;
    }
    
    // Create group management object
    var group = instance_create_depth(0, 0, 0, OBJ_CustomerGroup);
    group.group_size     = group_size;
    group.assigned_table = target_table;
    array_push(active_groups, group);
    
    // Mark table as occupied
    target_table.is_occupied   = true;
    target_table.current_group = group;
    
    var group_exit_x = (spawn_side == "left") ? spawn_left_exit_x : spawn_right_exit_x;

    // Store on group so customers know which side to exit from
    group.spawn_side = spawn_side;
    group.exit_x     = group_exit_x;
    group.exit_y     = group_spawn_y;
    
    // Spawn individual customers
    for (var i = 0; i < group_size; i++) {
        var customer_variants = [OBJ_Customer1, OBJ_Customer2];
        var random_variant    = customer_variants[irandom(array_length(customer_variants) - 1)];
        
        var customer = instance_create_depth(group_spawn_x, group_spawn_y + (i * 20), depth, random_variant);
        customer.my_group       = group;
        customer.my_table       = target_table;
        customer.my_chair_index = i;
        
        var chair_pos     = target_table.chair_positions[i];
        customer.target_x = target_table.x + chair_pos[0];
        customer.target_y = target_table.y + chair_pos[1];
        
        customer.create_path_to_target();
        customer.choose_order();
        
        array_push(group.customers, customer);
        array_push(target_table.customers_at_table, customer);
    }
    
    can_spawn = true;
}