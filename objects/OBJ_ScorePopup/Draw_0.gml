// Juicy score popup: soft glow, drop shadow, outline, colored value + sparkles.
draw_set_font(fnt_winkle);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var score_text = "+" + string(score_value);

// Soft radial glow behind the text
draw_set_alpha(alpha * 0.22);
draw_set_color(glow_color);
draw_circle(x, y, 30 * scale, false);
draw_set_alpha(alpha * 0.16);
draw_circle(x, y, 46 * scale, false);

// Drop shadow
draw_set_alpha(alpha * 0.5);
draw_set_color(c_black);
draw_text_transformed(x + 3, y + 4, score_text, scale, scale, 0);

// Black outline
draw_set_alpha(alpha);
draw_set_color(c_black);
var ot = 3;
for (var ox = -ot; ox <= ot; ox += ot) {
    for (var oy = -ot; oy <= ot; oy += ot) {
        if (ox != 0 || oy != 0) {
            draw_text_transformed(x + ox, y + oy, score_text, scale, scale, 0);
        }
    }
}

// Colored value
draw_set_color(text_color);
draw_text_transformed(x, y, score_text, scale, scale, 0);

// Twinkling sparkles flanking the value
var tw = 24 * scale;
var spark_n = 3;
for (var i = 0; i < spark_n; i++) {
    var ph = spark_phase + i * 2.094 + lifetime * 0.12;
    var sx = x + cos(ph) * (tw + i * 4);
    var sy = y + sin(ph * 1.3) * (14 * scale) - 10 * scale;
    var ss = (1.4 + sin(lifetime * 0.25 + i) * 0.8) * (scale * 0.5);
    if (ss <= 0) continue;
    draw_set_color(c_white);
    draw_set_alpha(alpha * (0.5 + 0.5 * sin(lifetime * 0.3 + i)));
    // 4-point sparkle (two crossed lines)
    draw_line_width(sx - ss * 2, sy, sx + ss * 2, sy, max(1, ss * 0.7));
    draw_line_width(sx, sy - ss * 2, sx, sy + ss * 2, max(1, ss * 0.7));
}

// Reset
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
