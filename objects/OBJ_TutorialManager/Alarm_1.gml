// alarm[1]
// Spawn tutorial customer
show_debug_message("Alarm 1 triggered! Current phase: " + current_phase + ", customer_spawned: " + string(customer_spawned));

if (current_phase == "serve" && !customer_spawned) {
    show_debug_message("Attempting to spawn customer...");
    // Find available table
    var target_table = instance_find(OBJ_Table1, 0);
    
    if (target_table != noone) {
        show_debug_message("Table found, creating customer...");
        // Use hardcoded spawn position instead of spawner
        var spawn_x = 100;  // Set your tutorial spawn point
        var spawn_y = 500;
        
        // Create customer
        tutorial_customer = instance_create_depth(spawn_x, spawn_y, -100, OBJ_Customer);
        tutorial_customer.my_table = target_table;
        tutorial_customer.my_chair_index = 0;
        
        // Set spawner to noone to prevent errors (IMPORTANT!)
        tutorial_customer.spawner = noone;
        
        // Set exit position directly (so customer knows where to go after eating)
        tutorial_customer.exit_x = spawn_x;
        tutorial_customer.exit_y = spawn_y;
        
        // Set target to first chair
        var chair_pos = target_table.chair_positions[0];
        tutorial_customer.target_x = target_table.x + chair_pos[0];
        tutorial_customer.target_y = target_table.y + chair_pos[1];
        
        // Force order to be PLATED Meat Lumpia
        tutorial_customer.ordered_food_type = "plated";
        tutorial_customer.order_sprite = spr_meatlumpiadish;
        tutorial_customer.order_name = "Meat Lumpia";
        
        // Mark table as occupied
        target_table.is_occupied = true;
        array_push(target_table.customers_at_table, tutorial_customer);
        
        // Create path (if using pathfinding)
        if (variable_instance_exists(tutorial_customer, "create_path_to_target")) {
            tutorial_customer.create_path_to_target();
        }
        
        customer_spawned = true;
        show_debug_message("Customer spawned successfully!");
    } else {
        show_debug_message("ERROR: No table found!");
    }
} else {
    show_debug_message("Conditions not met - phase: " + current_phase + ", already spawned: " + string(customer_spawned));
}