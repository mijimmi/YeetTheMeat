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

draw_sprite_ext(sprite_index, 0, x, y + bob_offset, draw_scale, draw_scale, 0, c_white, 1);