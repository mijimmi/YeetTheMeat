// Draw trash can with scale animation
draw_sprite_ext(sprite_index, 0, x, y, trash_scale, trash_scale, 0, c_white, 1);

// Show interaction hint
var nearest_player = instance_nearest(x, y, OBJ_P1);
if (nearest_player != noone) {
    var dist = point_distance(x, y, nearest_player.x, nearest_player.y);
    
    if (dist <= interact_range && nearest_player.held_item != noone) {
        var hint_text = "A - Trash Item";
        var hint_color = c_red;
        
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