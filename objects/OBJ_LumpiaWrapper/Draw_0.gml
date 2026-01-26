var current_speed = point_distance(0, 0, velocity_x, velocity_y);

var bob_offset = 0;
if (!is_held && current_speed < 0.3) {
    bob_offset = sin(bob_timer) * bob_amount;
}

// Scale when held
var draw_scale = 1;
if (is_held) {
    draw_scale = 0.7;
}

// Draw shadow when not held
if (!is_held) {
    var shadow_y = y + 25;
    var shadow_width = 18 * draw_scale;
    var shadow_height = 7 * draw_scale;
    
    draw_set_alpha(0.15);
    draw_set_color(c_black);
    draw_ellipse(x - shadow_width, shadow_y - shadow_height, x + shadow_width, shadow_y + shadow_height, false);
    
    draw_set_alpha(0.25);
    draw_ellipse(x - shadow_width * 0.7, shadow_y - shadow_height * 0.7, x + shadow_width * 0.7, shadow_y + shadow_height * 0.7, false);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}

draw_sprite_ext(sprite_index, 0, x, y + bob_offset, draw_scale, draw_scale, 0, c_white, 1);