draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Show interaction hint
var nearest_player = instance_nearest(x, y, OBJ_P1);
if (nearest_player != noone) {
    var dist = point_distance(x, y, nearest_player.x, nearest_player.y);
    
    if (dist <= interact_range && nearest_player.held_item != noone) {
        // Check if holding a plate with food
        if (instance_exists(nearest_player.held_item) && nearest_player.held_item.object_index == OBJ_Plate) {
            var plate = nearest_player.held_item;
            if (plate.has_food) {
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                
                draw_set_color(c_black);
                draw_text(x + 1, y - 50 + 1, "[A] Serve");
                
                draw_set_color(c_lime);
                draw_text(x, y - 50, "[A] Serve");
                
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }
        }
    }
}

// Show score
draw_set_halign(fa_center);
draw_set_valign(fa_top);

draw_set_color(c_black);
draw_text(x + 1, y + 40 + 1, "Orders: " + string(orders_completed));

draw_set_color(c_white);
draw_text(x, y + 40, "Orders: " + string(orders_completed));

draw_set_halign(fa_left);
draw_set_valign(fa_top);
