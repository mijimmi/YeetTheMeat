draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

var nearest_player = instance_nearest(x, y, OBJ_P1);
if (nearest_player != noone) {
    var dist = point_distance(x, y, nearest_player.x, nearest_player.y);
    
    if (dist <= interact_range) {
        var hint_text = "";
        var hint_color = c_white;
        
        if (nearest_player.held_item != noone && instance_exists(nearest_player.held_item)) {
            var item = nearest_player.held_item;
            var is_valid_ingredient = false;
            
            // Check if holding valid mixing ingredient
            if (object_is_ancestor(item.object_index, OBJ_Food)) {
                if (item.object_index == OBJ_Meat && item.food_type == "sliced") {
                    is_valid_ingredient = true;
                }
            } 
            else if (item.object_index == OBJ_Vegetables && item.veggie_state == "sliced") {
                is_valid_ingredient = true;
            }
            else if (item.object_index == OBJ_LumpiaWrapper) {
                is_valid_ingredient = true;
            }
            
            // Show hint based on station state
            if (is_valid_ingredient) {
                if (ingredient1 == noone) {
                    hint_text = "[A] Place Ingredient (1/2)";
                    hint_color = c_white;
                }
                else if (ingredient2 == noone && food_on_station == noone) {
                    hint_text = "[A] Place Ingredient (2/2)";
                    hint_color = c_yellow;
                }
            }
        }
        // Player empty-handed, result ready
        else if (nearest_player.held_item == noone && food_on_station != noone) {
            hint_text = "[X] Take Lumpia";
            hint_color = c_lime;
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