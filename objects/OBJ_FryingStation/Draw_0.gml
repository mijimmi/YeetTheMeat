draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Show interaction hint when player is near
var nearest_player = instance_nearest(x, y, OBJ_P1);
if (nearest_player != noone) {
    var dist = point_distance(x, y, nearest_player.x, nearest_player.y);
    
    if (dist <= interact_range) {
        var hint_text = "";
        
        // Player holding food, station empty
        if (nearest_player.held_item != noone && food_on_station == noone) {
            if (instance_exists(nearest_player.held_item) && object_is_ancestor(nearest_player.held_item.object_index, OBJ_Food)) {
                hint_text = "[X] Place Food";
            }
        }
        // Station has food, player empty-handed
        else if (food_on_station != noone && nearest_player.held_item == noone) {
            hint_text = "[A] Take Food";
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