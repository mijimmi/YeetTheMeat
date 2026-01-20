// === AIMING UI ===
if (state == "aiming") {
    
    var arrow_length = aim_power * arrow_length_max;
    var power_color = merge_color(arrow_color_weak, arrow_color_strong, aim_power);
    
    var arrow_x = x + lengthdir_x(arrow_length, aim_dir);
    var arrow_y = y + lengthdir_y(arrow_length, aim_dir);
    
    // --- ARROW SPRITE (rotated) ---
    var arrow_scale = 1 + (aim_power * 0.5);
    draw_sprite_ext(spr_P1Arrow, 0, arrow_x, arrow_y, arrow_scale, arrow_scale, aim_dir - 90, power_color, 1);
    
    // --- POWER BAR (Pixel Art Style) ---
    var bar_x = x + 35;
    var bar_y = y - 55;
    var bar_width = 10;
    var bar_height = 50;
    var segment_count = 8;
    var segment_height = bar_height / segment_count;
    var segment_gap = 2;
    
    // Outer border (chunky pixel style)
    draw_set_color(c_black);
    draw_rectangle(bar_x - 3, bar_y - 3, bar_x + bar_width + 3, bar_y + bar_height + 3, false);
    
    // Inner border (white frame)
    draw_set_color(c_white);
    draw_rectangle(bar_x - 2, bar_y - 2, bar_x + bar_width + 2, bar_y + bar_height + 2, false);
    
    // Background
    draw_set_color(c_dkgray);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
    
    // Segmented fill (chunky blocks)
    var filled_segments = floor(aim_power * segment_count);
    for (var seg = 0; seg < segment_count; seg++) {
        var seg_y = bar_y + bar_height - ((seg + 1) * segment_height) + 1;
        
        if (seg < filled_segments) {
            // Filled segment - gradient from green to red
            var seg_color = merge_color(arrow_color_weak, arrow_color_strong, seg / segment_count);
            draw_set_color(seg_color);
            draw_rectangle(bar_x + 1, seg_y + segment_gap, bar_x + bar_width - 1, seg_y + segment_height, false);
            
            // Highlight (cute shine on each block)
            draw_set_color(c_white);
            draw_set_alpha(0.5);
            draw_rectangle(bar_x + 1, seg_y + segment_gap, bar_x + 3, seg_y + segment_height - 2, false);
            draw_set_alpha(1);
        } else {
            // Empty segment (dark)
            draw_set_color(make_color_rgb(40, 40, 50));
            draw_rectangle(bar_x + 1, seg_y + segment_gap, bar_x + bar_width - 1, seg_y + segment_height, false);
        }
    }
    
    // Sparkle at max power
    if (aim_power >= 0.95) {
        var sparkle_offset = sin(current_time * 0.02) * 2;
        draw_set_color(c_white);
        draw_rectangle(bar_x + 4, bar_y - 10 + sparkle_offset, bar_x + 6, bar_y - 4 + sparkle_offset, false);
        draw_rectangle(bar_x + 2, bar_y - 8 + sparkle_offset, bar_x + 8, bar_y - 6 + sparkle_offset, false);
    }
    
    
    // --- TRAJECTORY PREVIEW ---
    if (aim_power > 0.1) {
        var preview_speed = aim_power * aim_power_max;
        var px = x;
        var py = y;
        var pvx = lengthdir_x(preview_speed, aim_dir);
        var pvy = lengthdir_y(preview_speed, aim_dir);
        
        draw_set_color(c_white);
        for (var i = 0; i < 30; i++) {
            if (i mod 2 == 0) {
                draw_set_alpha(1 - (i / 35));
                draw_circle(px, py, 1, false);
            }
            px += pvx * 0.5;
            py += pvy * 0.5;
            pvx *= friction_rate;
            pvy *= friction_rate;
        }
        draw_set_alpha(1);
    }
    
    // --- CANCEL HINT ---
    draw_set_halign(fa_center);
    draw_set_color(c_yellow);
    draw_text(x, y + 50, "[B] Cancel");
    draw_set_halign(fa_left);
}

// === RESET ===
draw_set_color(c_white);
draw_set_alpha(1);

// === DRAW HANDS (in front of body) ===
draw_sprite_ext(spr_1Hand, 0, x + hand1_x, y + hand1_y, hand_scale_x, hand_scale_y, hand1_angle, c_white, 1);
draw_sprite_ext(spr_1Hand, 0, x + hand2_x, y + hand2_y, -hand_scale_x, hand_scale_y, hand2_angle, c_white, 1);

// === DRAW PLAYER BODY ===
var squish_threshold = 0.75;
var sprite_to_use = spr_P1;

if (scale_y < squish_threshold || (state == "aiming" && aim_power >= 0.85)) {
    sprite_to_use = spr_P1Squish;
}

draw_sprite_ext(
    sprite_to_use,
    facing_frame,
    x, y,
    scale_x * facing_flip,
    scale_y,
    0,
    c_white,
    1
);


