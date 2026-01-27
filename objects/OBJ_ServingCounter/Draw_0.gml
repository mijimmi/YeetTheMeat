draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Find nearest player from both P1 and P2
var nearest_player = noone;
var nearest_dist = 999999;

var p1 = instance_nearest(x, y, OBJ_P1);
var p2 = instance_nearest(x, y, OBJ_P2);

if (p1 != noone) {
    var d1 = point_distance(x, y, p1.x, p1.y);
    if (d1 < nearest_dist) {
        nearest_dist = d1;
        nearest_player = p1;
    }
}
if (p2 != noone) {
    var d2 = point_distance(x, y, p2.x, p2.y);
    if (d2 < nearest_dist) {
        nearest_dist = d2;
        nearest_player = p2;
    }
}

if (nearest_player != noone) {
    var dist = nearest_dist;
    
    // Determine player color (P1 = red, P2 = orange)
    var player_color = (nearest_player.object_index == OBJ_P1) ? make_color_rgb(200, 60, 60) : make_color_rgb(220, 140, 40);
    
    if (dist <= interact_range) {
        var hint_text = "";
        var hint_color = c_white;
        
        // Player holding something
        if (nearest_player.held_item != noone && instance_exists(nearest_player.held_item)) {
            var item = nearest_player.held_item;
            
            // Holding plate (with or without food)
            if (item.object_index == OBJ_Plate) {
                if (plate_on_counter == noone) {
                    hint_text = "A  Place Plate";
                    hint_color = player_color;
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
                        hint_color = player_color;
                    }
                }
            }
        }
        // Player empty-handed, counter has plate
        else if (nearest_player.held_item == noone && plate_on_counter != noone) {
            if (plate_on_counter.has_food) {
                hint_text = "X  Take Plated Dish";
                hint_color = player_color;
            } else {
                hint_text = "X  Take Plate";
                hint_color = player_color;
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
            
            draw_set_color(hint_color);
            draw_text(x, y - 50, hint_text);
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}

