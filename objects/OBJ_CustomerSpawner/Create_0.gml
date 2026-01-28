// === SPAWNING CONFIGURATION ===
spawn_x = 100;            // Where customers spawn (adjust to your room entrance)
spawn_y = 500;
exit_x = 100;             // Where customers exit
exit_y = 300;

// === TIMING ===
spawn_timer = 0;

// Starting spawn delays (slow at first)
spawn_delay_min = 18 * 60;   // Start: Minimum 18 seconds between groups
spawn_delay_max = 25 * 60;   // Start: Maximum 25 seconds between groups

// Target spawn delays (after ramping up)
spawn_delay_min_target = 8 * 60;   // End: Minimum 8 seconds between groups
spawn_delay_max_target = 12 * 60;  // End: Maximum 12 seconds between groups

// Difficulty ramping
game_timer = 0;                    // Tracks total game time in frames
ramp_duration = 180 * 60;          // 3 minutes (180 seconds) to reach max difficulty

next_spawn_time = 0;

// === STATE ===
can_spawn = true;
active_groups = [];       // List of all active customer groups
first_customer_spawned = false;  // Track if first customer has appeared (to start timer)

// === AVAILABLE DISHES (What customers can order) ===
// Format: [food_type, order_sprite, display_name]
available_orders = [
    // Easy dishes
    ["plated", spr_ricedish, "Rice"],           
    ["plated", spr_takoyakidish, "Kwek-kwek"],
    ["gulaman", spr_gulaman, "Gulaman"],
    ["buko", spr_bukojuice, "Buko Juice"],
    
    // Medium dishes
    ["plated", spr_meatlumpiadish, "Meat Lumpia"],
    ["plated", spr_veggielumpiadish, "Veggie Lumpia"],
    ["plated", spr_adobodish, "Adobo"],
    
    // Hard dishes
    ["plated", spr_calderetadish, "Caldereta"]
];
// Set initial spawn time (use slow starting delay)
next_spawn_time = irandom_range(spawn_delay_min, spawn_delay_max);

function attempt_spawn_group() {
    // Determine group size with weighted probability
    // 1-2 customers are more common, 3-4 are less frequent
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
    
    // Find available table for this group size
    var available_table = find_available_table(group_size);
    
    if (available_table != noone) {
        spawn_customer_group(group_size, available_table);
    } else {
        // No tables available, wait for next cycle
        can_spawn = false;
        
        // Check if any tables become available
        alarm[0] = 60; // Check again in 1 second
    }
}

function find_available_table(group_size) {
    // Get all tables
    var tables_2chair = [OBJ_Table1, OBJ_Table2, OBJ_Table3, OBJ_Table4];
    var table_4chair = OBJ_Table5;
    
    // Groups of 3-4 MUST use 4-chair table
    if (group_size >= 3) {
        var table5 = instance_find(table_4chair, 0);
        if (table5 != noone && !table5.is_occupied) {
            return table5;
        }
        return noone; // No 4-chair table available
    }
    
    // Groups of 1-2 can use any table
    // First try 2-chair tables
    for (var i = 0; i < array_length(tables_2chair); i++) {
        var tbl = instance_find(tables_2chair[i], 0);
        if (tbl != noone && !tbl.is_occupied) {
            return tbl;
        }
    }
    
    // If no 2-chair available, try 4-chair
    var table5 = instance_find(table_4chair, 0);
    if (table5 != noone && !table5.is_occupied) {
        return table5;
    }
    
    return noone; // No tables available
}

function spawn_customer_group(group_size, target_table) {
    // SAFETY CHECK - validate table exists
    if (target_table == noone || !instance_exists(target_table)) {
        show_debug_message("ERROR: Invalid table passed to spawn_customer_group!");
        can_spawn = true;
        return;
    }
    
    // Start the timer when first customer appears
    if (!first_customer_spawned) {
        first_customer_spawned = true;
        if (instance_exists(OBJ_TimerController)) {
            OBJ_TimerController.start_timer();
        }
    }
    
    // Create group management object
    var group = instance_create_depth(0, 0, 0, OBJ_CustomerGroup);
    group.group_size = group_size;
    group.assigned_table = target_table;
    array_push(active_groups, group);
    
    // Mark table as occupied
    target_table.is_occupied = true;
    target_table.current_group = group;
    
    // Spawn individual customers
    for (var i = 0; i < group_size; i++) {
        var customer = instance_create_depth(spawn_x, spawn_y + (i * 20), depth, OBJ_Customer);
        customer.my_group = group;
        customer.my_table = target_table;
        customer.my_chair_index = i;
        
        // Set target position to specific chair at table
        var chair_pos = target_table.chair_positions[i];  // CHANGED: table → target_table
        customer.target_x = target_table.x + chair_pos[0];  // CHANGED: table → target_table
        customer.target_y = target_table.y + chair_pos[1];  // CHANGED: table → target_table

        // Create initial path
        customer.create_path_to_target();
        
        // Random order for this customer
        customer.choose_order();
        
        // Add to group and table
        array_push(group.customers, customer);
        array_push(target_table.customers_at_table, customer);
    }
    
    can_spawn = true; // Allow spawning again
}