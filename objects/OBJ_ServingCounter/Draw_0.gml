// Station sprite is invisible - only show interaction hints

// Helper function to get hint text for a player
function get_serving_hint(player) {
    var hint_text = "";
    
    // Player holding something
    if (player.held_item != noone && instance_exists(player.held_item)) {
        var item = player.held_item;
        
        // Holding plate (with or without food)
        if (item.object_index == OBJ_Plate) {
            if (plate_on_counter == noone) {
                hint_text = "A  Place Plate";
            }
        }
        // Holding cooked food, counter has empty plate
        else if (object_is_ancestor(item.object_index, OBJ_Food)) {
            if (plate_on_counter != noone && !plate_on_counter.has_food) {
                // Check if food is cooked/ready to plate
                if (item.food_type == "cooked" || 
                    item.food_type == "cooked_meat_lumpia" || 
                    item.food_type == "cooked_veggie_lumpia" ||
                    item.food_type == "fried_pork" ||
                    item.food_type == "adobo") {
                    hint_text = "A  Plate Food";
                }
            }
        }
    }
    // Player empty-handed, counter has plate
    else if (player.held_item == noone && plate_on_counter != noone) {
        if (plate_on_counter.has_food) {
            hint_text = "X  Take Plated Dish";
        } else {
            hint_text = "X  Take Plate";
        }
    }
    
    return hint_text;
}

// Check P1 hint - only if this is P1's closest station
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && global.p1_closest_station == id) {
    var dist = point_distance(x, y, p1.x, p1.y);
    if (dist <= interact_range) {
        var hint_text = get_serving_hint(p1);
        if (hint_text != "") {
            var player_color = make_color_rgb(200, 60, 60);
            
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
        var hint_text = get_serving_hint(p2);
        if (hint_text != "") {
            var player_color = make_color_rgb(220, 140, 40);
            var y_offset = -50;
            
            // Check if P1 also showing hint here
            if (p1 != noone && global.p1_closest_station == id) {
                var p1_hint = get_serving_hint(p1);
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
