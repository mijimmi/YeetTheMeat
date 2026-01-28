// === UPDATE ACTIVE HINTS ===
// Only show hints for the closest station to each player
active_hints = [];

// Check P1's closest station
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && instance_exists(p1)) {
    var closest = global.p1_closest_station;
    if (closest != noone && instance_exists(closest)) {
        // Check if this station has a hint sprite mapped
        var hint_spr = ds_map_find_value(hint_map, closest.object_index);
        if (hint_spr != undefined) {
            var can_interact = check_can_interact(p1, closest);
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
}

// Check P2's closest station
var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && instance_exists(p2)) {
    var closest = global.p2_closest_station;
    if (closest != noone && instance_exists(closest)) {
        // Check if this station has a hint sprite mapped
        var hint_spr = ds_map_find_value(hint_map, closest.object_index);
        if (hint_spr != undefined) {
            var can_interact = check_can_interact(p2, closest);
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
}

// === HELPER FUNCTION: Check if player can interact with station ===
function check_can_interact(player, station) {
    var held = player.held_item;
    var obj = station.object_index;
    
    // === STORAGE OBJECTS (Take items when empty-handed) ===
    if (object_is_ancestor(obj, OBJ_FoodStorage_Parent) || obj == OBJ_FoodStorage_Parent) {
        if (held == noone) {
            if (!variable_instance_exists(station, "spawn_cooldown") || station.spawn_cooldown <= 0) {
                return true;
            }
        }
    }
    
    // === FRYING STATION ===
    else if (obj == OBJ_FryingStation) {
        if (held == noone && variable_instance_exists(station, "food_on_station") && station.food_on_station != noone) {
            return true;
        }
        else if (held != noone && instance_exists(held) && variable_instance_exists(station, "food_on_station") && station.food_on_station == noone) {
            // Only sliced meat can be fried (not raw unsliced)
            if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "sliced") {
                return true;
            }
            // Only raw lumpia can be fried
            else if (held.object_index == OBJ_Lumpia && variable_instance_exists(held, "food_type")) {
                if (held.food_type == "raw_meat_lumpia" || held.food_type == "raw_veggie_lumpia") {
                    return true;
                }
            }
            else if (held.object_index == OBJ_KwekKwek && variable_instance_exists(held, "food_type") && held.food_type == "raw") {
                return true;
            }
            // Rice should NOT be fried - it cooks in the pot only
        }
    }
    
    // === POT STATION ===
    else if (obj == OBJ_PotStation) {
        if (held == noone && variable_instance_exists(station, "food_on_station") && station.food_on_station != noone) {
            return true;
        }
        else if (held != noone && instance_exists(held) && variable_instance_exists(station, "food_on_station") && station.food_on_station == noone) {
            if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "soy_sliced") {
                return true;
            }
            else if (held.object_index == OBJ_Rice && variable_instance_exists(held, "food_type") && held.food_type == "raw") {
                return true;
            }
            else if (held.object_index == OBJ_KwekKwek && variable_instance_exists(held, "food_type") && held.food_type == "raw") {
                return true;
            }
            // Raw caldereta (check food_type directly for reliability)
            else if (variable_instance_exists(held, "food_type") && held.food_type == "raw_caldereta") {
                return true;
            }
        }
    }
    
    // === SLICING STATION ===
    else if (obj == OBJ_SlicingStation) {
        // Don't show hints while processing
        if (variable_instance_exists(station, "is_processing") && station.is_processing) {
            return false;
        }
        if (held == noone && variable_instance_exists(station, "food_on_station") && station.food_on_station != noone) {
            return true;
        }
        else if (held != noone && instance_exists(held) && variable_instance_exists(station, "food_on_station") && station.food_on_station == noone) {
            if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "raw") {
                return true;
            }
            else if (held.object_index == OBJ_Vegetables && variable_instance_exists(held, "veggie_state") && held.veggie_state == "raw") {
                return true;
            }
        }
    }
    
    // === SOY SAUCE STATION ===
    else if (obj == OBJ_SoySauceStation) {
        // Don't show hints while processing
        if (variable_instance_exists(station, "is_processing") && station.is_processing) {
            return false;
        }
        if (held == noone && variable_instance_exists(station, "food_on_station") && station.food_on_station != noone) {
            return true;
        }
        else if (held != noone && instance_exists(held) && variable_instance_exists(station, "food_on_station") && station.food_on_station == noone) {
            if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "sliced") {
                return true;
            }
        }
    }
    
    // === MIXING STATION ===
    else if (obj == OBJ_MixingStation) {
        if (held == noone && variable_instance_exists(station, "food_on_station") && station.food_on_station != noone) {
            return true;
        }
        else if (held != noone && instance_exists(held)) {
            // Get held item type
            var item_type = "none";
            if (held.object_index == OBJ_LumpiaWrapper) {
                item_type = "wrapper";
            } else if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "sliced") {
                item_type = "sliced_meat";
            } else if (held.object_index == OBJ_Meat && variable_instance_exists(held, "food_type") && held.food_type == "soy_sliced") {
                item_type = "soy_meat";
            } else if (held.object_index == OBJ_Vegetables && variable_instance_exists(held, "veggie_state") && held.veggie_state == "sliced") {
                item_type = "sliced_veggie";
            }
            
            if (item_type == "none") return false;
            
            // First ingredient - any valid item is fine
            if (!variable_instance_exists(station, "ingredient1") || station.ingredient1 == noone) {
                return true;
            }
            // Second ingredient - check valid combo
            else if (variable_instance_exists(station, "ingredient2") && station.ingredient2 == noone) {
                var ing1 = station.ingredient1;
                var ing1_type = "none";
                if (ing1.object_index == OBJ_LumpiaWrapper) {
                    ing1_type = "wrapper";
                } else if (ing1.object_index == OBJ_Meat && variable_instance_exists(ing1, "food_type") && ing1.food_type == "sliced") {
                    ing1_type = "sliced_meat";
                } else if (ing1.object_index == OBJ_Meat && variable_instance_exists(ing1, "food_type") && ing1.food_type == "soy_sliced") {
                    ing1_type = "soy_meat";
                } else if (ing1.object_index == OBJ_Vegetables && variable_instance_exists(ing1, "veggie_state") && ing1.veggie_state == "sliced") {
                    ing1_type = "sliced_veggie";
                }
                
                // Valid combos
                if (ing1_type == "wrapper" && (item_type == "sliced_meat" || item_type == "sliced_veggie")) {
                    return true;
                } else if (ing1_type == "sliced_meat" && item_type == "wrapper") {
                    return true;
                } else if (ing1_type == "sliced_veggie" && (item_type == "wrapper" || item_type == "soy_meat")) {
                    return true;
                } else if (ing1_type == "soy_meat" && item_type == "sliced_veggie") {
                    return true;
                }
            }
        }
    }
    
    // === GULAMAN DISPENSER ===
    else if (obj == OBJ_GulamanDispenser) {
        if (held != noone && instance_exists(held) && held.object_index == OBJ_Drink) {
            if (variable_instance_exists(held, "drink_type") && held.drink_type == "empty") {
                return true;
            }
        }
    }
    
    // === BUKO DISPENSER ===
    else if (obj == OBJ_BukoDispenser) {
        if (held != noone && instance_exists(held) && held.object_index == OBJ_Drink) {
            if (variable_instance_exists(held, "drink_type") && held.drink_type == "empty") {
                return true;
            }
        }
    }
    
    // === TRASH CAN ===
    else if (obj == OBJ_TrashCan) {
        if (held != noone && instance_exists(held)) {
            return true;
        }
    }
    
    return false;
}
