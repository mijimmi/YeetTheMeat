event_inherited();

station_action = "Fill Gulaman";
accepted_state = "empty";
output_state = "";
requires_cooking = false;

// Override interact_place to handle drinks
function interact_place(player) {
    if (player.held_item != noone && instance_exists(player.held_item)) {
        if (food_on_station == noone) {
            var item = player.held_item;
            
            // Check if it's an empty cup
            if (item.object_index == OBJ_Drink && item.drink_type == "empty") {
                food_on_station = item;
                item.x = x + food_offset_x;
                item.y = y + food_offset_y;
                item.is_held = false;
                item.held_by = noone;
                item.can_slide = false;
                item.velocity_x = 0;
                item.velocity_y = 0;
                
                // Fill with gulaman
                item.drink_type = "gulaman";
                
                player.held_item = noone;
                return true;
            }
        }
    }
    return false;
}

function interact_take(player) {
    if (player.held_item == noone && food_on_station != noone) {
        player.held_item = food_on_station;
        player.held_item.is_held = true;
        player.held_item.held_by = player.id;
        player.held_item.can_slide = true;
        food_on_station = noone;
        return true;
    }
    return false;
}