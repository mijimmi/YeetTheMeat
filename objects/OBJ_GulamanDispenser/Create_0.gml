event_inherited();

// More forgiving interact range
interact_range = 110;

station_action = "Fill Gulaman";
accepted_state = "empty";
output_state = "";
requires_cooking = false;

// Override interact_place - fills cup while player holds it (instant fill)
function interact_place(player) {
    if (player.held_item != noone && instance_exists(player.held_item)) {
        var item = player.held_item;
        
        // Check if it's an empty cup - fill it instantly while player holds it
        if (item.object_index == OBJ_Drink && item.drink_type == "empty") {
            // Fill with gulaman (cup stays in player's hands)
            item.drink_type = "gulaman";
			item.food_type = "gulaman";
            return true;
        }
    }
    return false;
}

function interact_take(player) {
    // No taking needed - cup fills while held
    return false;
}