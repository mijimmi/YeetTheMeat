// Draw score popup with outline
draw_set_alpha(alpha);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var score_text = "+" + string(score_value);
var outline_thickness = 3;

// Draw black outline
draw_set_color(c_black);
for (var ox = -outline_thickness; ox <= outline_thickness; ox++) {
    for (var oy = -outline_thickness; oy <= outline_thickness; oy++) {
        if (ox != 0 || oy != 0) {
            draw_text_transformed(x + ox, y + oy, score_text, scale, scale, 0);
        }
    }
}

// Draw colored text
draw_set_color(text_color);
draw_text_transformed(x, y, score_text, scale, scale, 0);

// Reset draw settings
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
