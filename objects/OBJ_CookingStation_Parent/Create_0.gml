// === PARENT FOR ALL COOKING STATIONS ===
interact_range = 60;
food_on_station = noone;

// Visual offset
food_offset_x = 0;
food_offset_y = -20;

// Station behavior
station_action = "Cook";  // CHILD OVERRIDES (e.g., "Fry", "Slice", "Add Sauce", "Boil")

// Food state transitions (CHILD MUST SET THESE)
// Example: accepted_state = "raw", output_state = "sliced"
accepted_state = "";      // What state food must be to use this station
output_state = "";        // What state food becomes after processing
requires_cooking = true;  // Does this station use cooking timer? (false for instant stations like soy sauce)

// === INTERACTION FUNCTIONS ===
function interact_place(player) {
    if (player.held_item != noone && instance_exists(player.held_item) && object_is_ancestor(player.held_item.object_index, OBJ_Food)) {
        if (food_on_station == noone) {
            var food = player.held_item;
            
            // Check if food is in correct state (if specified)
            if (accepted_state == "" || food.food_type == accepted_state) {
                food_on_station = food;
                food.x = x + food_offset_x;
                food.y = y + food_offset_y;
                food.is_held = false;
                food.held_by = noone;
                
                if (requires_cooking) {
                    // Normal cooking station (frying, boiling)
                    food.is_cooking = true;
                    food.cooking_station = id;
                    food.cook_timer = 0;
                } else {
                    // Instant station (slicing, soy sauce)
                    food.food_type = output_state;
                    food.is_cooking = false;
                }
                
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
        player.held_item.is_cooking = false;
        player.held_item.cooking_station = noone;
        food_on_station = noone;
        return true;
    }
    return false;
}