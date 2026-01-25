event_inherited();

station_action = "Slice";
accepted_state = "raw";       
output_state = "sliced";      
requires_cooking = false;

// === OVERRIDE INTERACT_PLACE TO HANDLE BOTH FOOD AND VEGETABLES ===
function interact_place(player) {
    if (player.held_item != noone && instance_exists(player.held_item)) {
        if (food_on_station == noone) {
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
                
                // Transform the item
                if (object_is_ancestor(item.object_index, OBJ_Food)) {
                    item.food_type = "sliced";
                } else if (item.object_index == OBJ_Vegetables) {
                    item.veggie_state = "sliced";
                }
                
                player.held_item = noone;
                return true;
            }
        }
    }
    return false;
}