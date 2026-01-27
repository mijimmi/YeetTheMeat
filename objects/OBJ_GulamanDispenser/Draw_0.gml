draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

var nearest_player = instance_nearest(x, y, OBJ_P1);
if (nearest_player != noone) {
    var dist = point_distance(x, y, nearest_player.x, nearest_player.y);
    
    if (dist <= interact_range) {
        var hint_text = "";
        var hint_color = c_white;
        
        // Player holding empty cup, station empty
        if (nearest_player.held_item != noone && food_on_station == noone) {
            var item = nearest_player.held_item;
            if (item.object_index == OBJ_Drink && item.drink_type == "empty") {
                hint_text = "A - Fill Gulaman";
                hint_color = c_yellow;
            }
        }
        // Station has drink, player empty-handed
        else if (food_on_station != noone && nearest_player.held_item == noone) {
            hint_text = "X - Take Drink";
            hint_color = c_lime;
        }
        
        if (hint_text != "") {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            
            // Thick outline
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