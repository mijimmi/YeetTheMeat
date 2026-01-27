// Station sprite is invisible - only show interaction hints

// Helper function to draw hint
function draw_storage_hint(px, py, player_color, y_offset) {
    if (spawn_cooldown <= 0) {
        var hint_text = "X  Take " + storage_name;
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_black);
        for (var xx = -2; xx <= 2; xx++) {
            for (var yy = -2; yy <= 2; yy++) {
                if (xx != 0 || yy != 0) {
                    draw_text(x + xx, y + y_offset + yy, hint_text);
                }
            }
        }
        draw_set_color(player_color);
        draw_text(x, y + y_offset, hint_text);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}

// Check P1 hint - only if this is P1's closest station
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && global.p1_closest_station == id) {
    var dist = point_distance(x, y, p1.x, p1.y);
    if (dist <= interact_range && p1.held_item == noone) {
        draw_storage_hint(p1.x, p1.y, make_color_rgb(200, 60, 60), -40);
    }
}

// Check P2 hint - only if this is P2's closest station
var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && global.p2_closest_station == id) {
    var dist = point_distance(x, y, p2.x, p2.y);
    if (dist <= interact_range && p2.held_item == noone) {
        var y_offset = -40;
        if (p1 != noone && global.p1_closest_station == id && p1.held_item == noone) {
            y_offset = -60; // Move P2 hint higher
        }
        draw_storage_hint(p2.x, p2.y, make_color_rgb(220, 140, 40), y_offset);
    }
}
