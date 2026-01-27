// === SUBTLE GLOW (always visible) ===
var glow_color = make_color_rgb(255, 200, 190); // light pink/red for P1

// Outer soft glow
draw_set_alpha(0.12);
draw_set_color(glow_color);
draw_ellipse(x - 55, y - 30, x + 55, y + 70, false);

// Middle glow
draw_set_alpha(0.18);
draw_ellipse(x - 40, y - 15, x + 40, y + 55, false);

// Inner glow
draw_set_alpha(0.22);
draw_ellipse(x - 28, y - 5, x + 28, y + 45, false);

draw_set_alpha(1);
draw_set_color(c_white);

// === PLAYER INDICATOR (only after 2 seconds idle) ===
if (idle_timer >= idle_indicator_delay) {
    var indicator_y = y - 80;
    var outline_alpha = 0.6;
    var main_alpha = 0.9;
    var p1_color = make_color_rgb(180, 40, 40); // dark red
    var outline_offset = 2;
    
    // Draw white outline for triangle
    draw_set_alpha(outline_alpha);
    draw_set_color(c_white);
    draw_triangle(x - 6 - outline_offset, indicator_y - 6 - outline_offset, x + 6 + outline_offset, indicator_y - 6 - outline_offset, x, indicator_y + 3 + outline_offset, false);
    
    // Draw main triangle
    draw_set_alpha(main_alpha);
    draw_set_color(p1_color);
    draw_triangle(x - 6, indicator_y - 6, x + 6, indicator_y - 6, x, indicator_y + 3, false);
    
    // Draw P1 text with white outline
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    
    // White outline (draw text offset in multiple directions)
    draw_set_alpha(outline_alpha);
    draw_set_color(c_white);
    draw_text(x - 1, indicator_y - 8, "P1");
    draw_text(x + 1, indicator_y - 8, "P1");
    draw_text(x, indicator_y - 8 - 1, "P1");
    draw_text(x, indicator_y - 8 + 1, "P1");
    
    // Main text
    draw_set_alpha(main_alpha);
    draw_set_color(p1_color);
    draw_text(x, indicator_y - 8, "P1");
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}

// === DRAW SHADOW (SOFT) ===
var shadow_y_offset = 58;

// Outer soft shadow
draw_set_alpha(0.15);
draw_set_color(c_black);
draw_ellipse(x - 28 * scale_x, y + shadow_y_offset - 10, 
             x + 28 * scale_x, y + shadow_y_offset + 10, false);

// Inner darker shadow
draw_set_alpha(0.25);
draw_ellipse(x - 20 * scale_x, y + shadow_y_offset - 7, 
             x + 20 * scale_x, y + shadow_y_offset + 7, false);

draw_set_alpha(1);
draw_set_color(c_white);

// === DRAW CLOUD TRAIL ===
for (var i = 0; i < ds_list_size(cloud_list); i++) {
    var cloud = cloud_list[| i];
    var cx = cloud[0];
    var cy = cloud[1];
    var cscale = cloud[2];
    var calpha = cloud[3];
    var csprite = cloud[5];
    var crot = cloud[6];
    
    draw_sprite_ext(csprite, 0, cx, cy, cscale, cscale, crot, c_white, calpha);
}

// === AIMING UI ===
if (state == "aiming") {
    
    var arrow_length = aim_power * arrow_length_max;
    var power_color = merge_color(arrow_color_weak, arrow_color_strong, aim_power);
    
    var arrow_x = x + lengthdir_x(arrow_length, aim_dir);
    var arrow_y = y + lengthdir_y(arrow_length, aim_dir);
    
    // --- ARROW SPRITE (rotated) ---
    var arrow_scale = 1 + (aim_power * 0.5);
    draw_sprite_ext(spr_P1Arrow, 0, arrow_x, arrow_y, arrow_scale, arrow_scale, aim_dir - 90, power_color, 1);
    
    // --- POWER BAR (Hand-Drawn Style) ---
    var bar_x = x + 50;
    var bar_y = y - 50;
    var bar_width = 16;
    var bar_height = 58;

    var wobble_seed = floor(current_time * 0.002);
    random_set_seed(wobble_seed);

    draw_set_color(make_color_rgb(50, 40, 35));

    for (var stroke = 0; stroke < 3; stroke++) {
        var ox = random_range(-1, 1);
        var oy = random_range(-1, 1);
        draw_line_width(bar_x + ox, bar_y + oy, bar_x + random_range(-1, 1), bar_y + bar_height + oy, 2);
        draw_line_width(bar_x + bar_width + ox, bar_y + oy, bar_x + bar_width + random_range(-1, 1), bar_y + bar_height + oy, 2);
        draw_line_width(bar_x + ox, bar_y + oy, bar_x + bar_width + ox, bar_y + random_range(-1, 1), 2);
        draw_line_width(bar_x + ox, bar_y + bar_height + oy, bar_x + bar_width + ox, bar_y + bar_height + random_range(-1, 1), 2);
    }

    draw_set_color(make_color_rgb(240, 235, 220));
    draw_rectangle(bar_x + 2, bar_y + 2, bar_x + bar_width - 2, bar_y + bar_height - 2, false);

    draw_set_color(make_color_rgb(200, 190, 170));
    draw_set_alpha(0.4);
    for (var hatch = bar_y + 4; hatch < bar_y + bar_height - 2; hatch += 4) {
        draw_line(bar_x + 3, hatch, bar_x + bar_width - 3, hatch + 3);
    }
    draw_set_alpha(1);

    if (aim_power > 0.05) {
        var fill_height = aim_power * (bar_height - 8);
        var fill_bottom = bar_y + bar_height - 4;
        var fill_top = fill_bottom - fill_height;
        
        for (var fy = fill_bottom; fy > fill_top; fy -= 3) {
            var fill_progress = (fill_bottom - fy) / (bar_height - 8);
            
            var fill_color;
            if (fill_progress < 0.5) {
                fill_color = merge_color(make_color_rgb(100, 190, 80), make_color_rgb(230, 180, 50), fill_progress * 2);
            } else {
                fill_color = merge_color(make_color_rgb(230, 180, 50), make_color_rgb(210, 70, 60), (fill_progress - 0.5) * 2);
            }
            
            draw_set_color(fill_color);
            
            var stroke_wobble = sin(fy * 0.5) * 2;
            draw_line_width(
                bar_x + 4 + stroke_wobble,
                fy,
                bar_x + bar_width - 4 + stroke_wobble * 0.5,
                fy + random_range(-1, 1),
                3
            );
        }
        
        draw_set_color(c_white);
        draw_set_alpha(0.5);
        draw_line_width(bar_x + 5, fill_top + 5, bar_x + 6, fill_bottom - 5, 2);
        draw_set_alpha(1);
    }

    draw_set_color(make_color_rgb(50, 40, 35));
    draw_line_width(bar_x - 5, bar_y + bar_height, bar_x - 2, bar_y + bar_height, 1.5);
    draw_line_width(bar_x - 5, bar_y, bar_x - 2, bar_y, 1.5);

    for (var m = 1; m < 4; m++) {
        var mark_y = bar_y + (m * bar_height / 4);
        draw_line(bar_x - 4, mark_y, bar_x - 1, mark_y);
    }

    if (aim_power >= 0.95) {
        draw_set_color(make_color_rgb(210, 70, 60));
        var scrib_time = current_time * 0.008;
        
        for (var line = 0; line < 5; line++) {
            var angle = (line * 72) + sin(scrib_time + line) * 20;
            var dist1 = 12 + sin(scrib_time * 2 + line) * 3;
            var dist2 = 18 + sin(scrib_time * 3 + line) * 4;
            var cx = bar_x + bar_width/2;
            var cy = bar_y + 8;
            
            draw_line_width(
                cx + lengthdir_x(dist1, angle), cy + lengthdir_y(dist1, angle),
                cx + lengthdir_x(dist2, angle), cy + lengthdir_y(dist2, angle),
                1.5
            );
        }
        
        draw_set_color(make_color_rgb(240, 200, 50));
        var star_x = bar_x + bar_width + 8;
        var star_y = bar_y + 5 + sin(scrib_time * 2) * 2;
        draw_line_width(star_x - 4, star_y, star_x + 4, star_y, 2);
        draw_line_width(star_x, star_y - 4, star_x, star_y + 4, 2);
        draw_line_width(star_x - 3, star_y - 3, star_x + 3, star_y + 3, 1.5);
        draw_line_width(star_x + 3, star_y - 3, star_x - 3, star_y + 3, 1.5);
    }

    random_set_seed(current_time);
    
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
    if (cancel_hint_alpha > 0) {
        var hint_x = x;
        var hint_y = y + 75;
        var hint_text = "B";
        
        var hint_bounce = sin(current_time * 0.005) * 2;
        hint_y += hint_bounce;
        
        var pastel_pink = make_color_rgb(255, 180, 180);
        var pastel_cream = make_color_rgb(255, 250, 240);
        var sketch_brown = make_color_rgb(80, 60, 50);
        
        var hint_wobble_seed = floor(current_time * 0.003);
        random_set_seed(hint_wobble_seed);
        
        var pill_width = 36;
        var pill_height = 24;
        
        draw_set_alpha(cancel_hint_alpha * 0.9);
        draw_set_color(pastel_cream);
        draw_roundrect(hint_x - pill_width/2, hint_y - pill_height/2, hint_x + pill_width/2, hint_y + pill_height/2, false);
        
        draw_set_alpha(cancel_hint_alpha);
        draw_set_color(sketch_brown);
        for (var stroke = 0; stroke < 3; stroke++) {
            var ox = random_range(-1, 1);
            var oy = random_range(-1, 1);
            draw_roundrect(
                hint_x - pill_width/2 + ox, 
                hint_y - pill_height/2 + oy, 
                hint_x + pill_width/2 + ox, 
                hint_y + pill_height/2 + oy, 
                true
            );
        }
        
        draw_set_alpha(cancel_hint_alpha * 0.6);
        draw_set_color(pastel_pink);
        draw_circle(hint_x, hint_y, 10, false);
        
        draw_set_alpha(cancel_hint_alpha);
        draw_set_color(sketch_brown);
        for (var c = 0; c < 2; c++) {
            draw_circle(hint_x + random_range(-0.5, 0.5), hint_y + random_range(-0.5, 0.5), 10, true);
        }
        
        draw_set_alpha(cancel_hint_alpha);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(sketch_brown);
        draw_set_font(fnt_winkle);
        
        draw_text(hint_x + random_range(-0.5, 0.5), hint_y + random_range(-0.5, 0.5), hint_text);
        
        draw_set_alpha(cancel_hint_alpha * 0.7);
        draw_set_color(pastel_pink);
        draw_circle(hint_x - pill_width/2 - 6, hint_y - 2, 2, false);
        draw_circle(hint_x + pill_width/2 + 6, hint_y + 2, 2, false);
        
        draw_set_color(sketch_brown);
        draw_set_alpha(cancel_hint_alpha * 0.5);
        var sparkle_x = hint_x + pill_width/2 + 4;
        var sparkle_y = hint_y - pill_height/2 - 2;
        draw_line_width(sparkle_x - 3, sparkle_y, sparkle_x + 3, sparkle_y, 1);
        draw_line_width(sparkle_x, sparkle_y - 3, sparkle_x, sparkle_y + 3, 1);
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_font(-1);
        draw_set_alpha(1);
        
        random_set_seed(current_time);
    }
}

// === RESET ===
draw_set_color(c_white);
draw_set_alpha(1);

// === DRAW HANDS ===
draw_sprite_ext(spr_1Hand, hand_frame, x + hand1_x, y + hand1_y, hand_scale_x, hand_scale_y, hand1_angle, c_white, 1);
draw_sprite_ext(spr_1Hand, hand_frame, x + hand2_x, y + hand2_y, -hand_scale_x, hand_scale_y, hand2_angle, c_white, 1);

// === IDLE BLINK LOGIC ===
if (state == "idle") {
    if (blink_cooldown > 0) {
        blink_cooldown--;
    } else if (!is_blinking) {
        // Random chance to start blinking
        is_blinking = true;
        blink_timer = blink_duration;
        blink_cooldown = irandom_range(blink_cooldown_min, blink_cooldown_max);
    }
    
    if (is_blinking) {
        blink_timer--;
        if (blink_timer <= 0) {
            is_blinking = false;
        }
    }
} else {
    is_blinking = false;
}

// === DRAW PLAYER BODY ===
var squish_threshold = 0.75;
var sprite_to_use = spr_P1;

if (state == "moving") {
    sprite_to_use = spr_P1Dash;
}
else if (scale_y < squish_threshold || (state == "aiming" && aim_power >= 0.85)) {
    sprite_to_use = spr_P1Squish;
}
else if (is_blinking && state == "idle") {
    sprite_to_use = spr_P1Squish;  // Use squish sprite for blinking
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