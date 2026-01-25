draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Show interaction hint
var nearest_player = instance_nearest(x, y, OBJ_P1);
if (nearest_player != noone) {
    var dist = point_distance(x, y, nearest_player.x, nearest_player.y);
    
    if (dist <= interact_range) {
        var hint_text = "";
        var hint_color = c_white;
        
        // Player holding something
        if (nearest_player.held_item != noone && instance_exists(nearest_player.held_item)) {
            var item = nearest_player.held_item;
            
            // Holding plate (with or without food)
            if (item.object_index == OBJ_Plate) {
                if (plate_on_counter == noone) {
                    hint_text = "[A] Place Plate";
                    hint_color = c_white;
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
                        hint_text = "[A] Plate Food";
                        hint_color = c_yellow;
                    }
                }
            }
        }
        // Player empty-handed, counter has plate
        else if (nearest_player.held_item == noone && plate_on_counter != noone) {
            if (plate_on_counter.has_food) {
                hint_text = "[X] Take Plated Dish";
                hint_color = c_lime;
            } else {
                hint_text = "[X] Take Plate";
                hint_color = c_white;
            }
        }
        
        if (hint_text != "") {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            
            draw_set_color(c_black);
            draw_text(x + 1, y - 50 + 1, hint_text);
            
            draw_set_color(hint_color);
            draw_text(x, y - 50, hint_text);
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}

