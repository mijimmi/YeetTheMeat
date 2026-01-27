// Station sprite is invisible - only show interaction hints

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
    
    if (dist <= interact_range && nearest_player.held_item == noone && spawn_cooldown <= 0) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        var hint_text = "X  Take " + storage_name;
        
        // Draw thick black outline (8-directional)
        draw_set_color(c_black);
        for (var xx = -2; xx <= 2; xx++) {
            for (var yy = -2; yy <= 2; yy++) {
                if (xx != 0 || yy != 0) {
                    draw_text(x + xx, y - 40 + yy, hint_text);
                }
            }
        }
        
        // Draw colored text on top (based on player)
        draw_set_color(player_color);
        draw_text(x, y - 40, hint_text);
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}