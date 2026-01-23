var bob_offset = 0;
if (!is_held && !is_cooking) {
    bob_offset = sin(bob_timer) * bob_amount;
}

// Children will override sprite_index based on food_type
draw_sprite_ext(sprite_index, 0, x, y + bob_offset, 1, 1, 0, c_white, 1);

