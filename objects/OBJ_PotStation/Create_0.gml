event_inherited();

station_action = "Cook";
accepted_state = "";
output_state = "";
requires_cooking = true;

// Visual offset (optional)
food_offset_x = 0;
food_offset_y = -20;

// Override interact_place to only accept valid cookable items
function interact_place(player) {
    if (player.held_item != noone && instance_exists(player.held_item)) {
        if (food_on_station == noone) {
            var item = player.held_item;
            var can_cook = false;
            
            // Check what items can be boiled/cooked in pot
            if (item.object_index == OBJ_Meat && variable_instance_exists(item, "food_type")) {
                // Only soy_sliced meat can be cooked in pot (for adobo)
                if (item.food_type == "soy_sliced") {
                    can_cook = true;
                }
            }
            else if (item.object_index == OBJ_Rice && variable_instance_exists(item, "food_type")) {
                // Raw rice can be cooked
                if (item.food_type == "raw") {
                    can_cook = true;
                }
            }
            else if (item.object_index == OBJ_KwekKwek && variable_instance_exists(item, "food_type")) {
                // Raw kwek kwek can be cooked
                if (item.food_type == "raw") {
                    can_cook = true;
                }
            }
            // Raw caldereta can be cooked (check food_type directly for reliability)
            else if (variable_instance_exists(item, "food_type") && item.food_type == "raw_caldereta") {
                can_cook = true;
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
