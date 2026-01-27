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
                var can_interact = false;
                var held = player.held_item;
                
                // === STORAGE OBJECTS (Take items when empty-handed) ===
                if (object_is_ancestor(nearest.object_index, OBJ_FoodStorage_Parent) || nearest.object_index == OBJ_FoodStorage_Parent) {
                    if (held == noone) {
                        if (!variable_instance_exists(nearest, "spawn_cooldown") || nearest.spawn_cooldown <= 0) {
                            can_interact = true;
                        }
                    }
                }
                
                // === FRYING STATION ===
                else if (nearest.object_index == OBJ_FryingStation) {
                    // Can take if empty-handed and station has food
                    if (held == noone && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station != noone) {
                        can_interact = true;
                    }
                    // Can place if holding valid item and station empty
                    else if (held != noone && instance_exists(held) && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station == noone) {
                        // Accepts: sliced meat, raw lumpia, kwek kwek, rice
                        if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "sliced") {
                            can_interact = true;
                        }
                        else if (held.object_index == OBJ_Lumpia) {
                            can_interact = true;
                        }
                        else if (held.object_index == OBJ_KwekKwek && variable_instance_exists(held, "food_type") && held.food_type == "raw") {
                            can_interact = true;
                        }
                        else if (held.object_index == OBJ_Rice && variable_instance_exists(held, "food_type") && held.food_type == "raw") {
                            can_interact = true;
                        }
                    }
                }
                
                // === POT STATION ===
                else if (nearest.object_index == OBJ_PotStation) {
                    // Can take if empty-handed and station has food
                    if (held == noone && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station != noone) {
                        can_interact = true;
                    }
                    // Can place if holding valid item and station empty
                    else if (held != noone && instance_exists(held) && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station == noone) {
                        // Accepts: soy_sliced meat (for adobo), raw rice, raw kwek kwek
                        if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "soy_sliced") {
                            can_interact = true;
                        }
                        else if (held.object_index == OBJ_Rice && variable_instance_exists(held, "food_type") && held.food_type == "raw") {
                            can_interact = true;
                        }
                        else if (held.object_index == OBJ_KwekKwek && variable_instance_exists(held, "food_type") && held.food_type == "raw") {
                            can_interact = true;
                        }
                    }
                }
                
                // === SLICING STATION ===
                else if (nearest.object_index == OBJ_SlicingStation) {
                    // Can take if empty-handed and station has food
                    if (held == noone && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station != noone) {
                        can_interact = true;
                    }
                    // Can place if holding valid item and station empty
                    else if (held != noone && instance_exists(held) && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station == noone) {
                        // Accepts: raw meat, raw vegetables
                        if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "raw") {
                            can_interact = true;
                        }
                        else if (held.object_index == OBJ_Vegetables && variable_instance_exists(held, "veggie_state") && held.veggie_state == "raw") {
                            can_interact = true;
                        }
                    }
                }
                
                // === SOY SAUCE STATION ===
                else if (nearest.object_index == OBJ_SoySauceStation) {
                    // Can take if empty-handed and station has food
                    if (held == noone && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station != noone) {
                        can_interact = true;
                    }
                    // Can place if holding valid item and station empty
                    else if (held != noone && instance_exists(held) && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station == noone) {
                        // Accepts: sliced meat
                        if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "sliced") {
                            can_interact = true;
                        }
                    }
                }
                
                // === MIXING STATION ===
                else if (nearest.object_index == OBJ_MixingStation) {
                    // Can take if empty-handed and station has result
                    if (held == noone && variable_instance_exists(nearest, "food_on_station") && nearest.food_on_station != noone) {
                        can_interact = true;
                    }
                    // Can place ingredient
                    else if (held != noone && instance_exists(held)) {
                        // Accepts: sliced meat, sliced vegetables, lumpia wrapper
                        if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "sliced") {
                            can_interact = true;
                        }
                        else if (held.object_index == OBJ_Vegetables && variable_instance_exists(held, "veggie_state") && held.veggie_state == "sliced") {
                            can_interact = true;
                        }
                        else if (held.object_index == OBJ_LumpiaWrapper) {
                            can_interact = true;
                        }
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
