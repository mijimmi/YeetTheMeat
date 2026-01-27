event_inherited();

// More forgiving interact range
interact_range = 110;

station_action = "Fill Buko";
accepted_state = "empty";     // Only accepts empty cups
output_state = "";            // We handle manually
requires_cooking = false;     // Instant fill

// Override interact_place - fills cup while player holds it (instant fill)
function interact_place(player) {
    if (player.held_item != noone && instance_exists(player.held_item)) {
        var item = player.held_item;
        
        // Check if it's an empty cup - fill it instantly while player holds it
        if (item.object_index == OBJ_Drink && item.drink_type == "empty") {
            // Fill with buko (cup stays in player's hands)
            item.drink_type = "buko";
            return true;
        }
    }
    return false;
}

function interact_take(player) {
    // No taking needed - cup fills while held
    return false;
}