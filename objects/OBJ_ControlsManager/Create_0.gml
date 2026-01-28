// === BUTTON MAPPINGS ===
global.btn_take = gp_face3;      // X - Take from stations
global.btn_place = gp_face1;     // A - Place items on stations
global.btn_drop = gp_face4;      // Y - Drop items anywhere

// Stations that support TAKE action
global.stations_take = [
    OBJ_FoodStorage_Parent,     // Handles: Freezer, VeggieStorage, WrapperStorage
    OBJ_CookingStation_Parent,  // Handles: Frying, Pot, Slicing, SoySauce, Mixing
    OBJ_ServingCounter
];

// Stations that support PLACE action
global.stations_place = [
    OBJ_CookingStation_Parent,  // Handles: Frying, Pot, Slicing, SoySauce, Mixing
    OBJ_ServingCounter,
	OBJ_TrashCan,
	OBJ_GulamanDispenser,
	OBJ_BukoDispenser
];

// All interactable station types (for finding the closest)
global.all_stations = [
    OBJ_FoodStorage_Parent,
    OBJ_CookingStation_Parent,
    OBJ_ServingCounter,
    OBJ_TrashCan,
    OBJ_GulamanDispenser,
    OBJ_BukoDispenser
];

// Track the closest station for each player (used by station Draw events for hints)
global.p1_closest_station = noone;
global.p2_closest_station = noone;

// === HELPER FUNCTION: Find the closest station to a player ===
function find_closest_station(player_x, player_y) {
    var closest = noone;
    var closest_dist = 999999;
    
    for (var i = 0; i < array_length(global.all_stations); i++) {
        var station_type = global.all_stations[i];
        var nearest = instance_nearest(player_x, player_y, station_type);
        
        if (nearest != noone && instance_exists(nearest)) {
            var dist = point_distance(player_x, player_y, nearest.x, nearest.y);
            if (variable_instance_exists(nearest, "interact_range") && dist <= nearest.interact_range) {
                if (dist < closest_dist) {
                    closest_dist = dist;
                    closest = nearest;
                }
            }
        }
    }
    
    return closest;
}

// === INTERACTION FUNCTIONS ===

function player_interact_take(player_instance) {
    // X BUTTON - TAKE FROM STATIONS OR GROUND (whichever is closest)
    var interacted = false;
    
    with (player_instance) {
        // Find the absolute closest station
        var closest_station = OBJ_ControlsManager.find_closest_station(x, y);
        var station_dist = 999999;
        if (closest_station != noone) {
            station_dist = point_distance(x, y, closest_station.x, closest_station.y);
        }
        
        // Find closest ground item (only if empty-handed)
        var closest_ground_item = noone;
        var ground_item_dist = 999999;
        
        if (held_item == noone) {
            // Check plates (but exclude plates on serving counters)
            var nearest_plate = instance_nearest(x, y, OBJ_Plate);
            if (nearest_plate != noone && !nearest_plate.is_held) {
                // Check if this plate is on a serving counter
                var is_on_serving_counter = false;
                with (OBJ_ServingCounter) {
                    if (plate_on_counter == nearest_plate) {
                        is_on_serving_counter = true;
                        break;
                    }
                }
                
                // Only pick up if NOT on a counter (let station handle counter plates)
                if (!is_on_serving_counter) {
                    var d = point_distance(x, y, nearest_plate.x, nearest_plate.y);
                    if (d <= interact_range && d < ground_item_dist) {
                        ground_item_dist = d;
                        closest_ground_item = nearest_plate;
                    }
                }
            }
            
            // Check food (exclude food on stations)
            var nearest_food = instance_nearest(x, y, OBJ_Food);
            if (nearest_food != noone && !nearest_food.is_held && !nearest_food.is_cooking && !nearest_food.is_on_plate && nearest_food.cooking_station == noone) {
                var d = point_distance(x, y, nearest_food.x, nearest_food.y);
                if (d <= interact_range && d < ground_item_dist) {
                    ground_item_dist = d;
                    closest_ground_item = nearest_food;
                }
            }
            
            // Check vegetables (exclude if on station - can_slide is false when on station)
            var nearest_veggie = instance_nearest(x, y, OBJ_Vegetables);
            if (nearest_veggie != noone && !nearest_veggie.is_held && nearest_veggie.can_slide) {
                var d = point_distance(x, y, nearest_veggie.x, nearest_veggie.y);
                if (d <= interact_range && d < ground_item_dist) {
                    ground_item_dist = d;
                    closest_ground_item = nearest_veggie;
                }
            }
            
            // Check wrappers (exclude if on station - can_slide is false when on station)
            var nearest_wrapper = instance_nearest(x, y, OBJ_LumpiaWrapper);
            if (nearest_wrapper != noone && !nearest_wrapper.is_held && nearest_wrapper.can_slide) {
                var d = point_distance(x, y, nearest_wrapper.x, nearest_wrapper.y);
                if (d <= interact_range && d < ground_item_dist) {
                    ground_item_dist = d;
                    closest_ground_item = nearest_wrapper;
                }
            }
            
            // Check drinks
            var nearest_drink = instance_nearest(x, y, OBJ_Drink);
            if (nearest_drink != noone && !nearest_drink.is_held) {
                var d = point_distance(x, y, nearest_drink.x, nearest_drink.y);
                if (d <= interact_range && d < ground_item_dist) {
                    ground_item_dist = d;
                    closest_ground_item = nearest_drink;
                }
            }
        }
        
        // === SPECIAL CASE: Check for serving counters with plates ===
        // If empty-handed, prioritize serving counters that have a plate
        var serving_counter_with_plate = noone;
        var serving_counter_dist = 999999;
        
        if (held_item == noone) {
            with (OBJ_ServingCounter) {
                if (plate_on_counter != noone && instance_exists(plate_on_counter)) {
                    var d = point_distance(other.x, other.y, x, y);
                    if (d <= interact_range && d < serving_counter_dist) {
                        serving_counter_dist = d;
                        serving_counter_with_plate = id;
                    }
                }
            }
        }
        
        // Decide: prioritize serving counter with plate, then ground item, then closest station
        if (serving_counter_with_plate != noone && serving_counter_dist <= station_dist + 20) {
            // Serving counter with plate is close enough - use it
            interacted = serving_counter_with_plate.interact_take(id);
        }
        else if (closest_ground_item != noone && ground_item_dist < station_dist) {
            // Ground item is closer - pick it up
            held_item = closest_ground_item;
            closest_ground_item.is_held = true;
            closest_ground_item.held_by = id;
            interacted = true;
        }
        else if (closest_station != noone) {
            // Station is closer (or no ground item) - try station
            if (variable_instance_exists(closest_station, "interact_take")) {
                interacted = closest_station.interact_take(id);
            }
            
            // If station didn't work, try serving counter with plate as fallback
            if (!interacted && serving_counter_with_plate != noone) {
                interacted = serving_counter_with_plate.interact_take(id);
            }
            
            // If still nothing, try ground item as fallback
            if (!interacted && closest_ground_item != noone) {
                held_item = closest_ground_item;
                closest_ground_item.is_held = true;
                closest_ground_item.held_by = id;
                interacted = true;
            }
        }
        else if (closest_ground_item != noone) {
            // No station nearby, just pick up ground item
            held_item = closest_ground_item;
            closest_ground_item.is_held = true;
            closest_ground_item.held_by = id;
            interacted = true;
        }
    }
    return interacted;
}

function player_interact_place(player_instance) {
    // A BUTTON - PLACE ON STATIONS
    var interacted = false;
    
    with (player_instance) {
        // --- SERVE CUSTOMER (CHECK FIRST - HIGH PRIORITY) ---
        var nearest_customer = instance_nearest(x, y, OBJ_Customer);
        if (nearest_customer != noone && point_distance(x, y, nearest_customer.x, nearest_customer.y) <= interact_range) {
            if (held_item != noone && instance_exists(held_item)) {
                // Check if holding a plate with food
                if (held_item.object_index == OBJ_Plate && held_item.has_food) {
                    var food = held_item.food_on_plate;
                    
                    // Try to serve
                    if (nearest_customer.serve_food(food)) {
                        // Success! Destroy plate too
                        instance_destroy(held_item);
                        held_item = noone;
                        interacted = true;
                    }
                }
                // Also allow serving drinks directly
                else if (held_item.object_index == OBJ_Drink) {
                    if (nearest_customer.serve_food(held_item)) {
                        held_item = noone;
                        interacted = true;
                    }
                }
            }
        }
        
        if (interacted) {
            return true; // Exit early if served customer
        }
        
        // --- TRASH CAN ---
        var closest_station = OBJ_ControlsManager.find_closest_station(x, y);
        
        if (closest_station != noone) {
            // Special handling for trash can
            if (closest_station.object_index == OBJ_TrashCan) {
                if (held_item != noone && instance_exists(held_item)) {
                    var item_to_trash = held_item;
                    
                    // If trashing a plate with food, destroy the food too
                    if (item_to_trash.object_index == OBJ_Plate && item_to_trash.has_food) {
                        if (item_to_trash.food_on_plate != noone && instance_exists(item_to_trash.food_on_plate)) {
                            instance_destroy(item_to_trash.food_on_plate);
                        }
                    }
                    
                    // Destroy the item
                    instance_destroy(item_to_trash);
                    held_item = noone;
                    
                    // Animate trash can
                    closest_station.target_scale = 1.2;
                    closest_station.trash_timer = 10;
                    
                    interacted = true;
                }
            }
            // Regular station place
            else if (variable_instance_exists(closest_station, "interact_place")) {
                interacted = closest_station.interact_place(id);
            }
        }
        
        if (interacted) {
            return true; // Exit early if used station
        }
        
        // --- COMBINE PLATE + FOOD ON GROUND (FALLBACK) ---
        if (held_item != noone && instance_exists(held_item) && held_item.object_index == OBJ_Plate) {
            var plate = held_item;
            if (!plate.has_food) {
                var nearest_food = instance_nearest(x, y, OBJ_Food);
                if (nearest_food != noone && !nearest_food.is_held && !nearest_food.is_cooking) {
                    var dist = point_distance(x, y, nearest_food.x, nearest_food.y);
                    if (dist <= interact_range) {
                        plate.food_on_plate = nearest_food;
                        plate.has_food = true;
                        nearest_food.is_on_plate = true;
                        nearest_food.plate_instance = plate;
                        interacted = true;
                    }
                }
            }
        }
        else if (held_item != noone && instance_exists(held_item) && object_is_ancestor(held_item.object_index, OBJ_Food)) {
            var food = held_item;
            var nearest_plate = instance_nearest(x, y, OBJ_Plate);
            if (nearest_plate != noone && !nearest_plate.is_held && !nearest_plate.has_food) {
                var dist = point_distance(x, y, nearest_plate.x, nearest_plate.y);
                if (dist <= interact_range) {
                    nearest_plate.food_on_plate = food;
                    nearest_plate.has_food = true;
                    food.is_held = false;
                    food.held_by = noone;
                    food.is_on_plate = true;
                    food.plate_instance = nearest_plate;
                    
                    held_item = nearest_plate;
                    nearest_plate.is_held = true;
                    nearest_plate.held_by = id;
                    interacted = true;
                }
            }
        }
    }
    
    return interacted;
}

function player_drop_item(player_instance) {
    // Y BUTTON - DROP ANYWHERE
    var dropped = false;
    
    with (player_instance) {
        if (held_item != noone && instance_exists(held_item)) {
            held_item.x = x;
            held_item.y = y + 40;
            held_item.is_held = false;
            held_item.held_by = noone;
            
            if (object_is_ancestor(held_item.object_index, OBJ_Food)) {
                held_item.velocity_x = velocity_x * 0.5;
                held_item.velocity_y = velocity_y * 0.5;
            }
            else if (held_item.object_index == OBJ_Plate) {
                held_item.velocity_x = velocity_x * 0.5;
                held_item.velocity_y = velocity_y * 0.5;
            }
            else if (held_item.object_index == OBJ_Drink) {
                held_item.velocity_x = velocity_x * 0.5;
                held_item.velocity_y = velocity_y * 0.5;
            }
            
            if (held_item.object_index == OBJ_Plate && held_item.has_food) {
                var food = held_item.food_on_plate;
                if (food != noone && instance_exists(food)) {
                    food.x = x;
                    food.y = y + 30;
                    food.velocity_x = velocity_x * 0.5;
                    food.velocity_y = velocity_y * 0.5;
                }
            }
            
            held_item = noone;
            dropped = true;
        }
    }
    
    return dropped;
}
