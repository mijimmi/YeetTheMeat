// === TIMER BAR (Middle Left) ===
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

var timer_x = timer_margin_x;
var timer_y = (gui_height - timer_bar_height) / 2;  // Vertically centered

// Calculate timer progress (1.0 = full, 0.0 = empty)
var timer_progress = clamp(game_timer / timer_max, 0, 1);

// Convert timer to minutes:seconds
var total_seconds = floor(game_timer / 60);
var minutes = floor(total_seconds / 60);
var seconds = total_seconds mod 60;
var time_string = string(minutes) + ":" + (seconds < 10 ? "0" : "") + string(seconds);

// Hand-drawn bar style (matching power bar)
var wobble_seed = floor(current_time * 0.002);
random_set_seed(wobble_seed);

// Draw sketchy border (multiple strokes)
draw_set_color(make_color_rgb(50, 40, 35));
for (var stroke = 0; stroke < 3; stroke++) {
    var ox = random_range(-1, 1);
    var oy = random_range(-1, 1);
    // Left edge
    draw_line_width(timer_x + ox, timer_y + oy, timer_x + random_range(-1, 1), timer_y + timer_bar_height + oy, 2.5);
    // Right edge
    draw_line_width(timer_x + timer_bar_width + ox, timer_y + oy, timer_x + timer_bar_width + random_range(-1, 1), timer_y + timer_bar_height + oy, 2.5);
    // Top edge
    draw_line_width(timer_x + ox, timer_y + oy, timer_x + timer_bar_width + ox, timer_y + random_range(-1, 1), 2.5);
    // Bottom edge
    draw_line_width(timer_x + ox, timer_y + timer_bar_height + oy, timer_x + timer_bar_width + ox, timer_y + timer_bar_height + random_range(-1, 1), 2.5);
}

// Draw cream-colored background
draw_set_color(make_color_rgb(240, 235, 220));
draw_rectangle(timer_x + 3, timer_y + 3, timer_x + timer_bar_width - 3, timer_y + timer_bar_height - 3, false);

// Draw hatching pattern
draw_set_color(make_color_rgb(200, 190, 170));
draw_set_alpha(0.4);
for (var hatch = timer_y + 5; hatch < timer_y + timer_bar_height - 3; hatch += 5) {
    draw_line(timer_x + 4, hatch, timer_x + timer_bar_width - 4, hatch + 4);
}
draw_set_alpha(1);

// Draw fill (from bottom up)
if (timer_progress > 0.01) {
    var fill_height = timer_progress * (timer_bar_height - 10);
    var fill_bottom = timer_y + timer_bar_height - 5;
    var fill_top = fill_bottom - fill_height;
    
    for (var fy = fill_bottom; fy > fill_top; fy -= 4) {
        var fill_progress = (fill_bottom - fy) / (timer_bar_height - 10);
        
        // Color gradient: green (top) -> yellow -> red (empty)
        var fill_color;
        if (timer_progress > 0.5) {
            // Green to yellow
            var t = (timer_progress - 0.5) * 2;
            fill_color = merge_color(make_color_rgb(230, 180, 50), make_color_rgb(100, 190, 80), t);
        } else {
            // Yellow to red
            var t = timer_progress * 2;
            fill_color = merge_color(make_color_rgb(210, 70, 60), make_color_rgb(230, 180, 50), t);
        }
        
        draw_set_color(fill_color);
        
        var stroke_wobble = sin(fy * 0.5) * 2;
        draw_line_width(
            timer_x + 5 + stroke_wobble,
            fy,
            timer_x + timer_bar_width - 5 + stroke_wobble * 0.5,
            fy + random_range(-1, 1),
            4
        );
    }
    
    // Highlight
    draw_set_color(c_white);
    draw_set_alpha(0.4);
    draw_line_width(timer_x + 6, fill_top + 6, timer_x + 7, fill_bottom - 6, 2);
    draw_set_alpha(1);
}

// Draw tick marks on the side
draw_set_color(make_color_rgb(50, 40, 35));
draw_line_width(timer_x - 6, timer_y, timer_x - 2, timer_y, 1.5);
draw_line_width(timer_x - 6, timer_y + timer_bar_height, timer_x - 2, timer_y + timer_bar_height, 1.5);

// Quarter marks
for (var m = 1; m < 4; m++) {
    var mark_y = timer_y + (m * timer_bar_height / 4);
    draw_line(timer_x - 5, mark_y, timer_x - 2, mark_y);
}

// Draw time text with black outline (big, above bar)
draw_set_font(fnt_winkle);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);

var text_x = timer_x + timer_bar_width / 2;
var text_y = timer_y - 10;

// Black outline (8 directions)
draw_set_color(c_black);
draw_text_transformed(text_x - 2, text_y - 2, time_string, 2.2, 2.2, 0);
draw_text_transformed(text_x + 2, text_y - 2, time_string, 2.2, 2.2, 0);
draw_text_transformed(text_x - 2, text_y + 2, time_string, 2.2, 2.2, 0);
draw_text_transformed(text_x + 2, text_y + 2, time_string, 2.2, 2.2, 0);
draw_text_transformed(text_x - 2, text_y, time_string, 2.2, 2.2, 0);
draw_text_transformed(text_x + 2, text_y, time_string, 2.2, 2.2, 0);
draw_text_transformed(text_x, text_y - 2, time_string, 2.2, 2.2, 0);
draw_text_transformed(text_x, text_y + 2, time_string, 2.2, 2.2, 0);

// Main white text
draw_set_color(c_white);
draw_text_transformed(text_x, text_y, time_string, 2.2, 2.2, 0);

// Warning effects when low time
if (timer_progress < 0.25 && timer_active) {
    // Pulsing effect
    var pulse = 0.5 + sin(current_time * 0.01) * 0.5;
    
    draw_set_color(make_color_rgb(210, 70, 60));
    draw_set_alpha(pulse * 0.6);
    
    // Draw warning scribbles
    var scrib_time = current_time * 0.008;
    for (var line = 0; line < 4; line++) {
        var angle = (line * 90) + sin(scrib_time + line) * 20;
        var dist1 = 16 + sin(scrib_time * 2 + line) * 3;
        var dist2 = 22 + sin(scrib_time * 3 + line) * 4;
        var cx = text_x;
        var cy = text_y - 20;
        
        draw_line_width(
            cx + lengthdir_x(dist1, angle), cy + lengthdir_y(dist1, angle),
            cx + lengthdir_x(dist2, angle), cy + lengthdir_y(dist2, angle),
            2
        );
    }
    draw_set_alpha(1);
}

// Show "PAUSED" if timer not active (tutorial mode)
if (!timer_active && !game_finished) {
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    
    var pause_y = timer_y + timer_bar_height + 15;
    
    // Black outline
    draw_set_color(c_black);
    draw_text_transformed(text_x - 1, pause_y - 1, "READY", 1.2, 1.2, 0);
    draw_text_transformed(text_x + 1, pause_y - 1, "READY", 1.2, 1.2, 0);
    draw_text_transformed(text_x - 1, pause_y + 1, "READY", 1.2, 1.2, 0);
    draw_text_transformed(text_x + 1, pause_y + 1, "READY", 1.2, 1.2, 0);
    
    // Yellow text
    draw_set_color(make_color_rgb(230, 200, 80));
    draw_text_transformed(text_x, pause_y, "READY", 1.2, 1.2, 0);
}

// Show "TIME'S UP!" when finished
if (game_finished) {
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    
    var finish_y = timer_y + timer_bar_height + 15;
    var pulse = 0.7 + sin(current_time * 0.008) * 0.3;
    
    // Black outline
    draw_set_color(c_black);
    draw_text_transformed(text_x - 1, finish_y - 1, "TIME'S UP!", 1.4, 1.4, 0);
    draw_text_transformed(text_x + 1, finish_y - 1, "TIME'S UP!", 1.4, 1.4, 0);
    draw_text_transformed(text_x - 1, finish_y + 1, "TIME'S UP!", 1.4, 1.4, 0);
    draw_text_transformed(text_x + 1, finish_y + 1, "TIME'S UP!", 1.4, 1.4, 0);
    
    // Red pulsing text
    draw_set_alpha(pulse);
    draw_set_color(make_color_rgb(210, 70, 60));
    draw_text_transformed(text_x, finish_y, "TIME'S UP!", 1.4, 1.4, 0);
    draw_set_alpha(1);
}

random_set_seed(current_time);

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
