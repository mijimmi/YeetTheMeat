event_inherited();

station_action = "Fry Food";
accepted_state = "";      
output_state = "";           
requires_cooking = true;

// Visual offset (optional, parent has defaults)
food_offset_x = -50;
food_offset_y = -20;

// Override interact_place to only accept valid cookable items
function interact_place(player) {
    if (player.held_item != noone && instance_exists(player.held_item)) {
        if (food_on_station == noone) {
            var item = player.held_item;
            
            // Rice should NEVER be fried - reject immediately
            if (item.object_index == OBJ_Rice) {
                return false;
            }
            
            var can_cook = false;
            
            // Check what items can be fried
            if (item.object_index == OBJ_Meat && variable_instance_exists(item, "food_type")) {
                // Only sliced meat can be fried (not raw unsliced)
                if (item.food_type == "sliced") {
                    can_cook = true;
                }
            }
            else if (item.object_index == OBJ_Lumpia) {
                // Raw lumpia can be fried
                if (variable_instance_exists(item, "food_type")) {
                    if (item.food_type == "raw_meat_lumpia" || item.food_type == "raw_veggie_lumpia") {
                        can_cook = true;
                    }
                }
            }
            else if (item.object_index == OBJ_KwekKwek && variable_instance_exists(item, "food_type")) {
                // Raw kwek kwek can be fried
                if (item.food_type == "raw") {
                    can_cook = true;
                }
            }
            
            if (can_cook) {
                food_on_station = item;
                item.x = x + food_offset_x;
                item.y = y + food_offset_y;
                item.is_held = false;
                item.held_by = noone;
                item.can_slide = false;
                item.velocity_x = 0;
                item.velocity_y = 0;
                item.is_cooking = true;
                item.cooking_station = id;
                item.cook_timer = 0;
                
                player.held_item = noone;
                return true;
            }
        }
    }
    return false;
}