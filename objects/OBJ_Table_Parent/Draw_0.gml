// Draw table sprite
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Optional: Show occupied status
if (highlight_alpha > 0) {
    draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_red, highlight_alpha);
}

// Debug: Show chair positions (ENABLE THIS TO SEE WHERE CHAIRS ARE)

draw_set_color(c_lime);
for (var i = 0; i < array_length(chair_positions); i++) {
    var chair_x = x + chair_positions[i][0];
    var chair_y = y + chair_positions[i][1];
    draw_circle(chair_x, chair_y, 8, false);
    draw_set_color(c_white);
    draw_text(chair_x, chair_y - 15, "Chair " + string(i));
    draw_set_color(c_lime);
}
