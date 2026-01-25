draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Show interaction hint
var nearest_player = instance_nearest(x, y, OBJ_P1);
if (nearest_player != noone) {
    var dist = point_distance(x, y, nearest_player.x, nearest_player.y);
    
    if (dist <= interact_range) {
        var hint_text = "";
        
        // Check what action is available
        if (nearest_player.held_item != noone && instance_exists(nearest_player.held_item)) {
            // HOLDING PLATE - can place if counter is empty
            if (nearest_player.held_item.object_index == OBJ_Plate && plate_on_counter == noone) {
                hint_text = "[A] Place Plate";
            }
            // HOLDING FOOD - can plate if there's an empty plate on counter
            else if (object_is_ancestor(nearest_player.held_item.object_index, OBJ_Food)) {
                if (plate_on_counter != noone && !plate_on_counter.has_food) {
                    var food = nearest_player.held_item;
                    if (food.food_type == "cooked") {
                        hint_text = "[A] Plate Food";
                    }
                }
            }
        }
        // EMPTY HANDS - can take plate/food
        else if (nearest_player.held_item == noone && plate_on_counter != noone) {
            if (plate_on_counter.has_food) {
                hint_text = "[X] Take Dish";
            } else {
                hint_text = "[X] Take Plate";
            }
        }
        
        if (hint_text != "") {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            
            draw_set_color(c_black);
            draw_text(x + 1, y - 50 + 1, hint_text);
            
            draw_set_color(c_white);
            draw_text(x, y - 50, hint_text);
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}
