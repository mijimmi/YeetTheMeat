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
                hint_text = "[A] " + station_action;
                hint_color = c_white;
            }
        }
        // Station has food, player empty-handed - can take
        else if (food_on_station != noone && nearest_player.held_item == noone) {
            hint_text = "[X] Take Food";
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