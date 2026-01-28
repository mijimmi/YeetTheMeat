event_inherited();

station_action = "Slice";
accepted_state = "raw";
output_state = "sliced";
requires_cooking = false;

// === PROGRESS BAR SYSTEM ===
progress_max = 240; // 4 seconds at 60fps
progress_current = 0;
is_processing = false;
active_player = noone;  // Player who started the action
item_being_processed = noone;

// Bar styling
bar_width = 80;
bar_height = 14;
wobble_amount = 1.5;
line_segments = 3;

// === OVERRIDE INTERACT_TAKE TO PREVENT TAKING WHILE PROCESSING ===
function interact_take(player) {
    // Can't take while processing
    if (is_processing) {
        return false;
    }
    
    // Normal take logic
    if (player.held_item == noone && food_on_station != noone) {
        player.held_item = food_on_station;
        player.held_item.is_held = true;
        player.held_item.held_by = player.id;
        player.held_item.is_cooking = false;
        player.held_item.cooking_station = noone;
        player.held_item.can_slide = true;
        food_on_station = noone;
        return true;
    }
    return false;
}

// === OVERRIDE INTERACT_PLACE TO START PROGRESS ===
function interact_place(player) {
    if (player.held_item != noone && instance_exists(player.held_item)) {
        if (food_on_station == noone && !is_processing) {
            var item = player.held_item;
            var is_valid = false;
            
            // Check if it's food with "raw" state
            if (object_is_ancestor(item.object_index, OBJ_Food) && item.food_type == "raw") {
                is_valid = true;
            }
            // Check if it's vegetables with "raw" state
            else if (item.object_index == OBJ_Vegetables && item.veggie_state == "raw") {
                is_valid = true;
            }
            
            if (is_valid) {
                food_on_station = item;
                item.x = x + food_offset_x;
                item.y = y + food_offset_y;
                item.is_held = false;
                item.held_by = noone;
                item.can_slide = false;
                item.velocity_x = 0;
                item.velocity_y = 0;
                item.cooking_station = id;  // Mark as on station (prevents ground pickup)
                
                // Start processing instead of instant transform
                is_processing = true;
                progress_current = 0;
                active_player = player;
                item_being_processed = item;
                
                player.held_item = noone;
                return true;
            }
        }
    }
    return false;
}