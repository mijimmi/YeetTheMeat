draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

var nearest_player = instance_nearest(x, y, OBJ_P1);
if (nearest_player != noone) {
    var dist = point_distance(x, y, nearest_player.x, nearest_player.y);
    
    if (dist <= interact_range) {
        var hint_text = "";
        var hint_color = c_white;
        
        // Player holding something, station empty - can place
        if (nearest_player.held_item != noone && food_on_station == noone) {
            var item = nearest_player.held_item;
            var can_place = false;
            
            // Check if item is valid for this station
            if (object_is_ancestor(item.object_index, OBJ_Food)) {
                // Check if station has state requirement
                if (accepted_state == "" || item.food_type == accepted_state) {
                    can_place = true;
                }
            }
            else if (item.object_index == OBJ_Vegetables && variable_instance_exists(item, "veggie_state")) {
                if (accepted_state == "" || item.veggie_state == accepted_state) {
                    can_place = true;
                }
            }
            
            if (can_place) {
                hint_text = "A - " + station_action;
                hint_color = c_yellow;
            }
        }
        // Station has food, player empty-handed - check if done cooking
        else if (food_on_station != noone && nearest_player.held_item == noone) {
            // Only show hint if food is done cooking (or instant station)
            var is_done = false;
            
            if (requires_cooking) {
                // For cooking stations, check if food finished cooking
                if (instance_exists(food_on_station)) {
                    var food = food_on_station;
                    
                    // Check if food changed state (no longer raw/sliced)
                    if (food.food_type == "cooked" ||
                        food.food_type == "fried_pork" ||
                        food.food_type == "adobo" ||
                        food.food_type == "cooked_meat_lumpia" ||
                        food.food_type == "cooked_veggie_lumpia" ||
                        food.food_type == "burnt") {
                        is_done = true;
                    }
                }
            } else {
                // Instant stations (slicing, soy sauce) - always done
                is_done = true;
            }
            
            if (is_done) {
                hint_text = "X - Take Food";
                hint_color = c_lime;
            }
        }
        
        if (hint_text != "") {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            
            // Draw thick black outline (8-directional)
            draw_set_color(c_black);
            for (var xx = -2; xx <= 2; xx++) {
                for (var yy = -2; yy <= 2; yy++) {
                    if (xx != 0 || yy != 0) {
                        draw_text(x + xx, y - 50 + yy, hint_text);
                    }
                }
            }
            
            // Draw colored text on top
            draw_set_color(hint_color);
            draw_text(x, y - 50, hint_text);
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}