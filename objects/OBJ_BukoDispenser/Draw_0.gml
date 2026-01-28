// Station sprite is invisible - only show interaction hints

// Check P1 hint - only if this is P1's closest station
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && global.p1_closest_station == id) {
    var dist = point_distance(x, y, p1.x, p1.y);
    if (dist <= interact_range && p1.held_item != noone && instance_exists(p1.held_item)) {
        var item = p1.held_item;
        if (item.object_index == OBJ_Drink && item.drink_type == "empty") {
            var hint_text = "A  Fill Buko";
            var player_color = make_color_rgb(255, 100, 100);
            
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_black);
            for (var xx = -2; xx <= 2; xx++) {
                for (var yy = -2; yy <= 2; yy++) {
                    if (xx != 0 || yy != 0) {
                        draw_text(x + xx, y - 50 + yy, hint_text);
                    }
                }
            }
            draw_set_color(player_color);
            draw_text(x, y - 50, hint_text);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}

// Check P2 hint - only if this is P2's closest station
var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && global.p2_closest_station == id) {
    var dist = point_distance(x, y, p2.x, p2.y);
    if (dist <= interact_range && p2.held_item != noone && instance_exists(p2.held_item)) {
        var item = p2.held_item;
        if (item.object_index == OBJ_Drink && item.drink_type == "empty") {
            var hint_text = "A  Fill Buko";
            var player_color = make_color_rgb(220, 140, 40);
            var y_offset = -50;
            
            // Check if P1 also showing hint here
            if (p1 != noone && global.p1_closest_station == id && p1.held_item != noone && instance_exists(p1.held_item)) {
                if (p1.held_item.object_index == OBJ_Drink && p1.held_item.drink_type == "empty") {
                    y_offset = -70;
                }
            }
            
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
}
