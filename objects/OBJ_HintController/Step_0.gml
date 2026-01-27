// === UPDATE ACTIVE HINTS ===
active_hints = [];

// Check both players
var players = [instance_find(OBJ_P1, 0), instance_find(OBJ_P2, 0)];

for (var p = 0; p < array_length(players); p++) {
    var player = players[p];
    if (player == noone || !instance_exists(player)) continue;
    
    // Check all mapped objects for proximity
    var key = ds_map_find_first(hint_map);
    while (!is_undefined(key)) {
        var hint_spr = ds_map_find_value(hint_map, key);
        
        // Find nearest instance of this object type
        var nearest = instance_nearest(player.x, player.y, key);
        if (nearest != noone && instance_exists(nearest)) {
            var dist = point_distance(player.x, player.y, nearest.x, nearest.y);
            
            // Use station's interact_range if available, otherwise use default
            var check_range = hint_range;
            if (variable_instance_exists(nearest, "interact_range")) {
                check_range = nearest.interact_range;
            }
            
            if (dist <= check_range) {
                // Only show hint if player can actually interact (has text hint)
                var can_interact = false;
                
                // Check for FoodStorage_Parent (Take items)
                if (object_is_ancestor(nearest.object_index, OBJ_FoodStorage_Parent) || nearest.object_index == OBJ_FoodStorage_Parent) {
                    // Can take if player empty-handed and no cooldown
                    if (player.held_item == noone) {
                        if (variable_instance_exists(nearest, "spawn_cooldown") && nearest.spawn_cooldown <= 0) {
                            can_interact = true;
                        } else if (!variable_instance_exists(nearest, "spawn_cooldown")) {
                            can_interact = true;
                        }
                    }
                }
                // Check for CookingStation_Parent (Place/Take)
                else if (object_is_ancestor(nearest.object_index, OBJ_CookingStation_Parent) || nearest.object_index == OBJ_CookingStation_Parent) {
                    // Can place if holding something and station empty
                    if (player.held_item != noone && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station == noone) {
                        can_interact = true;
                    }
                    // Can take if empty-handed and station has food
                    else if (player.held_item == noone && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station != noone) {
                        can_interact = true;
                    }
                }
                // Check for MixingStation
                else if (nearest.object_index == OBJ_MixingStation) {
                    // Can place ingredient
                    if (player.held_item != noone) {
                        can_interact = true;
                    }
                    // Can take result
                    else if (player.held_item == noone && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station != noone) {
                        can_interact = true;
                    }
                }
                // Check for ServingCounter
                else if (nearest.object_index == OBJ_ServingCounter) {
                    // Can place plate or food
                    if (player.held_item != noone) {
                        can_interact = true;
                    }
                    // Can take plate
                    else if (player.held_item == noone && variable_instance_exists(nearest, "plate_on_counter") && nearest.plate_on_counter != noone) {
                        can_interact = true;
                    }
                }
                
                if (can_interact) {
                    // Check if this hint is already in the list
                    var already_added = false;
                    for (var i = 0; i < array_length(active_hints); i++) {
                        if (active_hints[i] == hint_spr) {
                            already_added = true;
                            break;
                        }
                    }
                    
                    if (!already_added) {
                        array_push(active_hints, hint_spr);
                    }
                }
            }
        }
        
        key = ds_map_find_next(hint_map, key);
    }
}
