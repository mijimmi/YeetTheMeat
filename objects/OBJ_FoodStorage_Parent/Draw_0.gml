draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

var nearest_player = instance_nearest(x, y, OBJ_P1);
if (nearest_player != noone) {
    var dist = point_distance(x, y, nearest_player.x, nearest_player.y);
    
    if (dist <= interact_range && nearest_player.held_item == noone && spawn_cooldown <= 0) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        var hint_text = "[X] Take " + storage_name;
        
        draw_set_color(c_black);
        draw_text(x + 1, y - 40 + 1, hint_text);
        
        draw_set_color(c_white);
        draw_text(x, y - 40, hint_text);
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}