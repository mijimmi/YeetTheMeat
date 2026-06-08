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

spawn_delay_min = 8 * 60;
spawn_delay_max = 12 * 60;

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
    
    // Hard dishes
    ["plated",  spr_calderetadish,    "Caldereta"]
];

next_spawn_time = irandom_range(spawn_delay_min, spawn_delay_max);

function attempt_spawn_group() {
    var roll = irandom(99);
    var group_size;
    if (roll < 40) {
        group_size = 1;      // 40% chance
    } else if (roll < 75) {
        group_size = 2;      // 35% chance
    } else if (roll < 90) {
        group_size = 3;      // 15% chance
    } else {
        group_size = 4;      // 10% chance
    }
    
    var available_table = find_available_table(group_size);
    
    if (available_table != noone) {
        spawn_customer_group(group_size, available_table);
    } else {
        can_spawn = false;
        alarm[0] = 60;
    }
}

function find_available_table(group_size) {
    var tables_2chair = [OBJ_Table1, OBJ_Table2, OBJ_Table3, OBJ_Table4];
    var tables_4chair = [OBJ_Table5, OBJ_Table6];

    if (group_size == 4) {
        for (var i = 0; i < array_length(tables_4chair); i++) {
            var tbl = instance_find(tables_4chair[i], 0);
            if (tbl != noone && !tbl.is_occupied) {
                return tbl;
            }
        }
        return noone;
    }

    if (group_size == 3) {
        for (var i = 0; i < array_length(tables_4chair); i++) {
            var tbl = instance_find(tables_4chair[i], 0);
            if (tbl != noone && !tbl.is_occupied) {
                return tbl;
            }
        }
        return noone;
    }

    // Groups of 1-2: try 2-chair first, then 4-chair
    for (var i = 0; i < array_length(tables_2chair); i++) {
        var tbl = instance_find(tables_2chair[i], 0);
        if (tbl != noone && !tbl.is_occupied) {
            return tbl;
        }
    }
    for (var i = 0; i < array_length(tables_4chair); i++) {
        var tbl = instance_find(tables_4chair[i], 0);
        if (tbl != noone && !tbl.is_occupied) {
            return tbl;
        }
    }

    return noone;
}

function spawn_customer_group(group_size, target_table) {
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
    
    // === PICK A RANDOM SIDE FOR THE WHOLE GROUP ===
    var spawn_side    = (irandom(1) == 0) ? "left" : "right";
    var group_spawn_x = (spawn_side == "left") ? spawn_left_x  : spawn_right_x;
    var group_exit_x  = (spawn_side == "left") ? spawn_left_exit_x : spawn_right_exit_x;
    
	var group_spawn_y = irandom_range(360, 720);
    
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