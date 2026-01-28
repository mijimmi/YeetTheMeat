// Station sprite is invisible - only show interaction hints

// Helper function to get hint text for a player
function get_mixing_hint(player) {
    var hint_text = "";
    
    if (player.held_item != noone && instance_exists(player.held_item)) {
        var item = player.held_item;
        
        // Get item type
        var item_type = "none";
        if (item.object_index == OBJ_LumpiaWrapper) {
            item_type = "wrapper";
        } else if (item.object_index == OBJ_Meat && item.food_type == "sliced") {
            item_type = "sliced_meat";
        } else if (item.object_index == OBJ_Meat && item.food_type == "soy_sliced") {
            item_type = "soy_meat";
        } else if (item.object_index == OBJ_Vegetables && item.veggie_state == "sliced") {
            item_type = "sliced_veggie";
        }
        
        // Show hint based on station state
        if (item_type != "none") {
            if (ingredient1 == noone) {
                hint_text = "A  Place Ingredient 1";
            }
            else if (ingredient2 == noone && food_on_station == noone) {
                // Check if this would be a valid combination
                var ing1_type = "none";
                if (ingredient1.object_index == OBJ_LumpiaWrapper) {
                    ing1_type = "wrapper";
                } else if (ingredient1.object_index == OBJ_Meat && ingredient1.food_type == "sliced") {
                    ing1_type = "sliced_meat";
                } else if (ingredient1.object_index == OBJ_Meat && ingredient1.food_type == "soy_sliced") {
                    ing1_type = "soy_meat";
                } else if (ingredient1.object_index == OBJ_Vegetables && ingredient1.veggie_state == "sliced") {
                    ing1_type = "sliced_veggie";
                }
                
                // Valid combos: wrapper+sliced_meat, wrapper+sliced_veggie, soy_meat+sliced_veggie
                var valid_combo = false;
                if (ing1_type == "wrapper" && (item_type == "sliced_meat" || item_type == "sliced_veggie")) {
                    valid_combo = true;
                } else if (ing1_type == "sliced_meat" && item_type == "wrapper") {
                    valid_combo = true;
                } else if (ing1_type == "sliced_veggie" && (item_type == "wrapper" || item_type == "soy_meat")) {
                    valid_combo = true;
                } else if (ing1_type == "soy_meat" && item_type == "sliced_veggie") {
                    valid_combo = true;
                }
                
                if (valid_combo) {
                    hint_text = "A  Place Ingredient 2";
                }
            }
        }
    }
    // Player empty-handed, result ready
    else if (player.held_item == noone && food_on_station != noone) {
        hint_text = "X  Take Food";
    }
    
    return hint_text;
}

// Check P1 hint - only if this is P1's closest station
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && global.p1_closest_station == id) {
    var dist = point_distance(x, y, p1.x, p1.y);
    if (dist <= interact_range) {
        var hint_text = get_mixing_hint(p1);
        if (hint_text != "") {
            var player_color = make_color_rgb(255, 100, 100);
            
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
        var hint_text = get_mixing_hint(p2);
        if (hint_text != "") {
            var player_color = make_color_rgb(220, 140, 40);
            var y_offset = -50;
            
            // Check if P1 also showing hint here
            if (p1 != noone && global.p1_closest_station == id) {
                var p1_hint = get_mixing_hint(p1);
                if (p1_hint != "") {
                    y_offset = -70;
                }
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
