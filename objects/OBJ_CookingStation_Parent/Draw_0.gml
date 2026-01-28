// Station sprite is invisible - only show interaction hints

// Helper function to check if item can be placed on this station
function can_item_be_placed(item) {
    // For Frying Station
    if (object_index == OBJ_FryingStation) {
        if (item.object_index == OBJ_Meat && variable_instance_exists(item, "food_type") && item.food_type == "sliced") {
            return true;
        }
        if (item.object_index == OBJ_Lumpia && variable_instance_exists(item, "food_type")) {
            if (item.food_type == "raw_meat_lumpia" || item.food_type == "raw_veggie_lumpia") {
                return true;
            }
        }
        if (item.object_index == OBJ_KwekKwek && variable_instance_exists(item, "food_type") && item.food_type == "raw") {
            return true;
        }
        if (item.object_index == OBJ_Rice && variable_instance_exists(item, "food_type") && item.food_type == "raw") {
            return true;
        }
        return false;
    }
    
    // For Pot Station
    if (object_index == OBJ_PotStation) {
        if (item.object_index == OBJ_Meat && variable_instance_exists(item, "food_type") && item.food_type == "soy_sliced") {
            return true;
        }
        if (item.object_index == OBJ_Rice && variable_instance_exists(item, "food_type") && item.food_type == "raw") {
            return true;
        }
        if (item.object_index == OBJ_KwekKwek && variable_instance_exists(item, "food_type") && item.food_type == "raw") {
            return true;
        }
        // Caldereta (raw_caldereta can be cooked in pot)
        if (variable_instance_exists(item, "food_type") && item.food_type == "raw_caldereta") {
            return true;
        }
        return false;
    }
    
    // For Slicing Station
    if (object_index == OBJ_SlicingStation) {
        if (item.object_index == OBJ_Meat && variable_instance_exists(item, "food_type") && item.food_type == "raw") {
            return true;
        }
        if (item.object_index == OBJ_Vegetables && variable_instance_exists(item, "veggie_state") && item.veggie_state == "raw") {
            return true;
        }
        return false;
    }
    
    // For Soy Sauce Station
    if (object_index == OBJ_SoySauceStation) {
        if (item.object_index == OBJ_Meat && variable_instance_exists(item, "food_type") && item.food_type == "sliced") {
            return true;
        }
        return false;
    }
    
    // Default: use parent logic (accepted_state check)
    if (object_is_ancestor(item.object_index, OBJ_Food)) {
        if (accepted_state == "" || item.food_type == accepted_state) {
            return true;
        }
    }
    else if (item.object_index == OBJ_Vegetables && variable_instance_exists(item, "veggie_state")) {
        if (accepted_state == "" || item.veggie_state == accepted_state) {
            return true;
        }
    }
    return false;
}

// Check P1 hint - only if this is P1's closest station
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && global.p1_closest_station == id) {
    var dist = point_distance(x, y, p1.x, p1.y);
    if (dist <= interact_range) {
        var hint_text = "";
        var player_color = make_color_rgb(255, 100, 100);
        
        // Player holding something, station empty - can place
        if (p1.held_item != noone && food_on_station == noone) {
            var item = p1.held_item;
            
            if (can_item_be_placed(item)) {
                hint_text = "A  " + station_action;
            }
        }
        // Station has food, player empty-handed
        else if (food_on_station != noone && p1.held_item == noone) {
            var is_done = false;
            
            if (requires_cooking) {
                if (instance_exists(food_on_station)) {
                    var food = food_on_station;
                    if (food.food_type == "cooked" ||
                        food.food_type == "fried_pork" ||
                        food.food_type == "adobo" ||
                        food.food_type == "cooked_meat_lumpia" ||
                        food.food_type == "cooked_veggie_lumpia" ||
                        food.food_type == "cooked_caldereta" ||
                        food.food_type == "burnt") {
                        is_done = true;
                    }
                }
            } else {
                is_done = true;
            }
            
            if (is_done) {
                hint_text = "X  Take Food";
            }
        }
        
        if (hint_text != "") {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_black);
            for (var xx = -2; xx <= 2; xx++) {
                for (var yy = -2; yy <= 2; yy++) {
                    if (xx != 0 || yy != 0) {
                        draw_text(x + xx, y - 50 + yy, hint_text);
                    }
                }
            }
            draw_set_color(player_color);
            draw_text(x, y - 50, hint_text);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}

// Check P2 hint - only if this is P2's closest station
var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && global.p2_closest_station == id) {
    var dist = point_distance(x, y, p2.x, p2.y);
    if (dist <= interact_range) {
        var hint_text = "";
        var player_color = make_color_rgb(220, 140, 40);
        
        // Player holding something, station empty - can place
        if (p2.held_item != noone && food_on_station == noone) {
            var item = p2.held_item;
            
            if (can_item_be_placed(item)) {
                hint_text = "A  " + station_action;
            }
        }
        // Station has food, player empty-handed
        else if (food_on_station != noone && p2.held_item == noone) {
            var is_done = false;
            
            if (requires_cooking) {
                if (instance_exists(food_on_station)) {
                    var food = food_on_station;
                    if (food.food_type == "cooked" ||
                        food.food_type == "fried_pork" ||
                        food.food_type == "adobo" ||
                        food.food_type == "cooked_meat_lumpia" ||
                        food.food_type == "cooked_veggie_lumpia" ||
                        food.food_type == "cooked_caldereta" ||
                        food.food_type == "burnt") {
                        is_done = true;
                    }
                }
            } else {
                is_done = true;
            }
            
            if (is_done) {
                hint_text = "X  Take Food";
            }
        }
        
        if (hint_text != "") {
            // Draw slightly offset if P1 also has a hint here
            var y_offset = -50;
            if (p1 != noone && global.p1_closest_station == id) {
                y_offset = -70; // Move P2 hint higher
            }
            
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_black);
            for (var xx = -2; xx <= 2; xx++) {
                for (var yy = -2; yy <= 2; yy++) {
                    if (xx != 0 || yy != 0) {
                        draw_text(x + xx, y + y_offset + yy, hint_text);
                    }
                }
            }
            draw_set_color(player_color);
            draw_text(x, y + y_offset, hint_text);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}