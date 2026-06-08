// === BUTTON MAPPINGS ===
global.btn_action = gp_face3;    // X - Context-sensitive action (take/place/interact)
global.btn_drop = gp_face4;      // Y - Drop items anywhere

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

// === INPUT PROMPT HELPERS ===
// Returns the action-button label for a player based on their current device
function get_action_key(player_instance) {
    if (player_instance != noone && instance_exists(player_instance)) {
        if (variable_instance_exists(player_instance, "prompt_use_keyboard") && player_instance.prompt_use_keyboard) {
            // P2 (slot 1) uses U, P1 (slot 0) uses E
            if (variable_instance_exists(player_instance, "gamepad_slot") && player_instance.gamepad_slot == 1) {
                return "U";
            }
            return "E";
        }
        if (variable_instance_exists(player_instance, "gamepad_slot")) {
            return gamepad_is_connected(player_instance.gamepad_slot) ? "X" : "E";
        }
    }
    return "X";
}

// Draws a bigger, brighter, cute interaction prompt.
// hint_text is expected to begin with the "X  " placeholder key.
function draw_action_prompt(px, py, hint_text, player_instance, player_color) {
    if (hint_text == "") return;

    // Strip the leading "X" placeholder (keep the spacing after it)
    var label = hint_text;
    if (string_char_at(hint_text, 1) == "X") {
        label = string_delete(hint_text, 1, 1);
    }

    var key = get_action_key(player_instance);
    var prompt = key + label;

    // Brighten the player color for better visibility
    var bright = merge_color(player_color, c_white, 0.3);

    var s = 1.25; // Slightly bigger than default, but compact
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // Thick black outline for readability
    draw_set_color(c_black);
    for (var ox = -3; ox <= 3; ox += 3) {
        for (var oy = -3; oy <= 3; oy += 3) {
            if (ox != 0 || oy != 0) {
                draw_text_transformed(px + ox, py + oy, prompt, s, s, 0);
            }
        }
    }

    // Bright fill
    draw_set_color(bright);
    draw_text_transformed(px, py, prompt, s, s, 0);

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// === UNIFIED ACTION FUNCTION ===
function player_action(player_instance) {
    // Context-sensitive: if holding item -> place/serve; if empty -> take/pickup
    var interacted = false;
    
    with (player_instance) {
        var closest_station = OBJ_ControlsManager.find_closest_station(x, y);
        var station_dist = 999999;
        if (closest_station != noone) {
            station_dist = point_distance(x, y, closest_station.x, closest_station.y);
        }
        
        // === HOLDING AN ITEM: Try to PLACE/SERVE ===
        if (held_item != noone && instance_exists(held_item)) {
            // --- SERVE CUSTOMER (HIGH PRIORITY) ---
            var nearest_customer = instance_nearest(x, y, OBJ_Customer_Parent);
            if (nearest_customer != noone && point_distance(x, y, nearest_customer.x, nearest_customer.y) <= interact_range) {
                if (held_item.object_index == OBJ_Plate && held_item.has_food) {
                    var food = held_item.food_on_plate;
                    if (nearest_customer.serve_food(food)) {
                        audio_sound_gain(sfx_serve, 0.5, 0);
                        audio_play_sound(sfx_serve, 1, false);
                        instance_destroy(held_item);
                        held_item = noone;
                        interacted = true;
                    }
                }
                else if (held_item.object_index == OBJ_Drink) {
                    if (nearest_customer.serve_food(held_item)) {
                        audio_sound_gain(sfx_serve, 0.5, 0);
                        audio_play_sound(sfx_serve, 1, false);
                        held_item = noone;
                        interacted = true;
                    }
                }
            }
            
            if (interacted) return true;
            
            // --- TRASH CAN ---
            if (closest_station != noone && closest_station.object_index == OBJ_TrashCan) {
                var item_to_trash = held_item;
                
                audio_sound_gain(sfx_interact, 0.5, 0);
                audio_play_sound(sfx_interact, 1, false);
                
                if (item_to_trash.object_index == OBJ_Plate && item_to_trash.has_food) {
                    if (item_to_trash.food_on_plate != noone && instance_exists(item_to_trash.food_on_plate)) {
                        instance_destroy(item_to_trash.food_on_plate);
                    }
                }
                
                instance_destroy(item_to_trash);
                held_item = noone;
                
                closest_station.target_scale = 1.2;
                closest_station.trash_timer = 10;
                
                interacted = true;
            }
            // --- INSTANT PLATE COOKED FOOD AT COOKING STATION ---
            else if (held_item.object_index == OBJ_Plate && !held_item.has_food) {
                if (closest_station != noone && object_is_ancestor(closest_station.object_index, OBJ_CookingStation_Parent)) {
                    if (variable_instance_exists(closest_station, "interact_plate_here")) {
                        interacted = closest_station.interact_plate_here(id);
                    }
                }
                // Not a cooking station — fall through to regular place (e.g. ServingCounter)
                if (!interacted && closest_station != noone && variable_instance_exists(closest_station, "interact_place")) {
                    interacted = closest_station.interact_place(id);
                }
            }
            // --- REGULAR STATION PLACE ---
            else if (closest_station != noone && variable_instance_exists(closest_station, "interact_place")) {
                interacted = closest_station.interact_place(id);
            }
            
            if (interacted) return true;
            
            // --- COMBINE PLATE + FOOD ON GROUND ---
            if (held_item.object_index == OBJ_Plate) {
                var plate = held_item;
                if (!plate.has_food) {
                    var nearest_food = instance_nearest(x, y, OBJ_Food);
                    if (nearest_food != noone && !nearest_food.is_held && !nearest_food.is_cooking) {
                        var dist = point_distance(x, y, nearest_food.x, nearest_food.y);
                        if (dist <= interact_range) {
                            var is_ready_to_plate = (
                                nearest_food.food_type == "cooked" ||
                                nearest_food.food_type == "fried_pork" ||
                                nearest_food.food_type == "adobo" ||
                                nearest_food.food_type == "cooked_meat_lumpia" ||
                                nearest_food.food_type == "cooked_veggie_lumpia" ||
                                nearest_food.food_type == "cooked_caldereta"
                            );
                            
                            if (is_ready_to_plate) {
                                plate.food_on_plate = nearest_food;
                                plate.has_food = true;
                                nearest_food.is_on_plate = true;
                                nearest_food.plate_instance = plate;
                                
                                audio_sound_gain(sfx_item_pickup, 1.0, 0);
                                audio_play_sound(sfx_item_pickup, 1, false);
                                
                                interacted = true;
                            }
                        }
                    }
                }
            }
            else if (object_is_ancestor(held_item.object_index, OBJ_Food)) {
                var food = held_item;
                var nearest_plate = instance_nearest(x, y, OBJ_Plate);
                if (nearest_plate != noone && !nearest_plate.is_held && !nearest_plate.has_food) {
                    var dist = point_distance(x, y, nearest_plate.x, nearest_plate.y);
                    if (dist <= interact_range) {
                        var is_ready_to_plate = (
                            food.food_type == "cooked" ||
                            food.food_type == "fried_pork" ||
                            food.food_type == "adobo" ||
                            food.food_type == "cooked_meat_lumpia" ||
                            food.food_type == "cooked_veggie_lumpia" ||
                            food.food_type == "cooked_caldereta"
                        );
                        
                        if (is_ready_to_plate) {
                            nearest_plate.food_on_plate = food;
                            nearest_plate.has_food = true;
                            food.is_held = false;
                            food.held_by = noone;
                            food.is_on_plate = true;
                            food.plate_instance = nearest_plate;
                            
                            held_item = nearest_plate;
                            nearest_plate.is_held = true;
                            nearest_plate.held_by = id;
                            
                            audio_sound_gain(sfx_item_pickup, 1.0, 0);
                            audio_play_sound(sfx_item_pickup, 1, false);
                            
                            interacted = true;
                        }
                    }
                }
            }
            
            return interacted;
        }
        
        // === EMPTY HANDED: Try to TAKE/PICKUP ===
        // Find closest ground item
        var closest_ground_item = noone;
        var ground_item_dist = 999999;
        
        // Check plates (but exclude plates on serving counters)
        var nearest_plate = instance_nearest(x, y, OBJ_Plate);
        if (nearest_plate != noone && !nearest_plate.is_held) {
            var is_on_serving_counter = false;
            with (OBJ_ServingCounter) {
                if (plate_on_counter == nearest_plate) {
                    is_on_serving_counter = true;
                    break;
                }
            }
            
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
        
        // Check vegetables (exclude if on station)
        var nearest_veggie = instance_nearest(x, y, OBJ_Vegetables);
        if (nearest_veggie != noone && !nearest_veggie.is_held && nearest_veggie.can_slide) {
            var d = point_distance(x, y, nearest_veggie.x, nearest_veggie.y);
            if (d <= interact_range && d < ground_item_dist) {
                ground_item_dist = d;
                closest_ground_item = nearest_veggie;
            }
        }
        
        // Check wrappers (exclude if on station)
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
        
        // Check serving counters with plates
        var serving_counter_with_plate = noone;
        var serving_counter_dist = 999999;
        
        with (OBJ_ServingCounter) {
            if (plate_on_counter != noone && instance_exists(plate_on_counter)) {
                var d = point_distance(other.x, other.y, x, y);
                if (d <= interact_range && d < serving_counter_dist) {
                    serving_counter_dist = d;
                    serving_counter_with_plate = id;
                }
            }
        }
        
        // Decide priority: serving counter with plate > station > ground item
        if (serving_counter_with_plate != noone && serving_counter_dist <= station_dist + 20) {
            interacted = serving_counter_with_plate.interact_take(id);
            if (interacted) {
                audio_sound_gain(sfx_item_pickup, 0.5, 0);
                audio_play_sound(sfx_item_pickup, 1, false);
            }
        }
        else if (closest_station != noone && station_dist <= ground_item_dist) {
            // Station is closer - try take from station
            if (variable_instance_exists(closest_station, "interact_take")) {
                interacted = closest_station.interact_take(id);
                if (interacted) {
                    audio_sound_gain(sfx_item_pickup, 0.5, 0);
                    audio_play_sound(sfx_item_pickup, 1, false);
                }
            }
            
            // Fallback to ground item
            if (!interacted && closest_ground_item != noone) {
                held_item = closest_ground_item;
                closest_ground_item.is_held = true;
                closest_ground_item.held_by = id;
                audio_sound_gain(sfx_item_pickup, 1.0, 0);
                audio_play_sound(sfx_item_pickup, 1, false);
                interacted = true;
            }
        }
        else if (closest_ground_item != noone) {
            held_item = closest_ground_item;
            closest_ground_item.is_held = true;
            closest_ground_item.held_by = id;
            audio_sound_gain(sfx_item_pickup, 1.0, 0);
            audio_play_sound(sfx_item_pickup, 1, false);
            interacted = true;
        }
        else if (closest_station != noone) {
            // No ground item, try station take
            if (variable_instance_exists(closest_station, "interact_take")) {
                interacted = closest_station.interact_take(id);
                if (interacted) {
                    audio_sound_gain(sfx_item_pickup, 0.5, 0);
                    audio_play_sound(sfx_item_pickup, 1, false);
                }
            }
        }
    }
    return interacted;
}

function player_drop_item(player_instance) {
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
            
            audio_sound_gain(sfx_item_drop, 0.4, 0);
            audio_play_sound(sfx_item_drop, 1, false);
            
            held_item = noone;
            dropped = true;
        }
    }
    
    return dropped;
}
