var bob_offset = 0;
if (!is_held) {
    bob_offset = sin(bob_timer) * bob_amount;
}

draw_sprite_ext(sprite_index, 0, x, y + bob_offset, 1, 1, 0, c_white, 1);

// Debug: Show state
if (is_held) {
    draw_set_color(c_lime);
    draw_circle(x, y, 5, false);
    draw_set_color(c_white);
}