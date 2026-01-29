// OBJ_Scoring Draw GUI Event
// NOTE: Text size controlled by scale parameters in draw_text_transformed()
//       Adjust font_size variable below to change text size globally

if (show_results) {
    // Get screen dimensions
    var screen_w = display_get_gui_width();
    var screen_h = display_get_gui_height();
    
    // Draw background
    draw_sprite_stretched(spr_scoreAfterRun, 0, 0, 0, screen_w, screen_h);
    
    // Text positioning - ADJUST HERE for left/right positioning
    var text_x = screen_w / 2.45;  // Horizontal position (slightly left of center)
    var text_y = screen_h / 3;    // Vertical center
    
    // Text properties - ADJUST HERE
    var font_size = 3;            // Base font scale (3x normal size)
    var tilt_angle = -16;         // 15 degrees tilt to the left
    
    // SPACING SETTINGS - ADJUST THESE VALUES TO CONTROL LINE DISTANCES
    var title_offset = 160;       // Title position from center (currently 120px above center)
    var line_spacing = 70;        // Space between score lines (currently 40px between lines)
    var restart_offset = 200;     // Restart text position from center (120px below center)
    
    // OUTLINE SETTINGS - ADJUST THESE FOR OUTLINE THICKNESS
    var outline_thickness = 3;    // Thickness of black outline (higher = thicker)
    
    // Set text alignment to center (for tilted text)
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Draw text with black outline first (multiple times for thickness)
    draw_set_color(c_black);
    
    // Function to draw outlined text (simplifies the process) - PASS thickness as parameter
    function draw_outlined_text(_x, _y, _text, _xscale, _yscale, _angle, _thickness) {
        // Draw black outline in multiple directions
        for (var i = 0; i < 360; i += 90 / _thickness) {
            var dir = i;
            var ox = lengthdir_x(_thickness, dir);
            var oy = lengthdir_y(_thickness, dir);
            draw_text_transformed(_x + ox, _y + oy, _text, _xscale, _yscale, _angle);
        }
        
        // Quick 8-direction outline for better coverage
        for (var ox = -_thickness; ox <= _thickness; ox += _thickness) {
            for (var oy = -_thickness; oy <= _thickness; oy += _thickness) {
                if (ox != 0 || oy != 0) {
                    draw_text_transformed(_x + ox, _y + oy, _text, _xscale, _yscale, _angle);
                }
            }
        }
    }
    
    // Draw all text with black outline - PASS outline_thickness as last parameter
    // Title with outline
    draw_outlined_text(text_x, text_y - title_offset, "RUN COMPLETE!", font_size, font_size, tilt_angle, outline_thickness);
    
    // Score lines with outline
    draw_outlined_text(text_x, text_y - (line_spacing * 1), "Final Score: " + string(total_score), font_size, font_size, tilt_angle, outline_thickness);
    draw_outlined_text(text_x, text_y + (line_spacing * 0), "Orders Completed: " + string(orders_completed), font_size, font_size, tilt_angle, outline_thickness);
    draw_outlined_text(text_x, text_y + (line_spacing * 1), "Orders Failed: " + string(orders_failed), font_size, font_size, tilt_angle, outline_thickness);
    
    // Restart instruction with outline
    draw_outlined_text(text_x, text_y + restart_offset, "Press A to Restart", font_size, font_size, tilt_angle, outline_thickness);
    
    // Now draw white text on top (centered)
    draw_set_color(c_white);
    
    // Draw all text with 3x size, left tilt (-15), and consistent spacing
    draw_text_transformed(text_x, text_y - title_offset, "RUN COMPLETE!", font_size, font_size, tilt_angle);
    draw_text_transformed(text_x, text_y - (line_spacing * 1), "Final Score: " + string(total_score), font_size, font_size, tilt_angle);
    draw_text_transformed(text_x, text_y + (line_spacing * 0), "Orders Completed: " + string(orders_completed), font_size, font_size, tilt_angle);
    draw_text_transformed(text_x, text_y + (line_spacing * 1), "Orders Failed: " + string(orders_failed), font_size, font_size, tilt_angle);
    draw_text_transformed(text_x, text_y + restart_offset, "Press A to Restart", font_size, font_size, tilt_angle);
    
    // Restart on button press
    if (gamepad_button_check_pressed(0, gp_face1)) {
        room_restart();
    }
    
    // Reset alignment
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
else {
    // === NORMAL IN-GAME HUD (HAND-DRAWN STYLE) ===
    var cam = view_camera[0];
    var cam_width = camera_get_view_width(cam);
    var cam_height = camera_get_view_height(cam);
    
    // HUD positioning - BIGGER SIZE
    var hud_x = 30;           // Distance from left edge
    var hud_y = 25;           // Distance from top edge
    var line_height = 50;     // Space between HUD lines (bigger spacing)
    
    // HUD OUTLINE SETTINGS
    var hud_outline_thickness = 3;  // Thicker outline for hand-drawn feel
    
    // Calculate panel size dynamically
    var panel_padding = 20;
    var panel_width = 225;    // Half width
    var panel_height = 240;   // Taller panel
    
    // Hand-drawn wobble effect
    var wobble_seed = floor(current_time * 0.002);
    random_set_seed(wobble_seed);
    
    // Draw hand-drawn style background with sketchy lines
    var sketch_brown = make_color_rgb(50, 40, 35);
    var cream_bg = make_color_rgb(250, 245, 235);
    
    // Shadow (offset and soft) - hand-drawn style
    draw_set_alpha(0.25);
    draw_set_color(c_black);
    for (var s = 0; s < 2; s++) {
        var sx = random_range(-1, 1);
        var sy = random_range(-1, 1);
        draw_roundrect(hud_x - panel_padding + 6 + sx, hud_y - panel_padding + 6 + sy, 
                       hud_x + panel_width + 6 + sx, hud_y + panel_height + 6 + sy, false);
    }
    draw_set_alpha(1);
    
    // Main panel background (cream colored) - hand-drawn with reduced opacity
    draw_set_alpha(0.75); // Reduced opacity from 1.0
    draw_set_color(cream_bg);
    draw_roundrect(hud_x - panel_padding, hud_y - panel_padding, 
                   hud_x + panel_width, hud_y + panel_height, false);
    
    // Texture lines for paper feel
    draw_set_alpha(0.2); // Reduced from 0.3
    draw_set_color(make_color_rgb(240, 235, 225));
    for (var tx = hud_x - panel_padding; tx < hud_x + panel_width; tx += 8) {
        draw_line(tx, hud_y - panel_padding, tx, hud_y + panel_height);
    }
    draw_set_alpha(1);
    
    // Hand-drawn border (multiple sketchy strokes)
    draw_set_color(sketch_brown);
    for (var stroke = 0; stroke < 5; stroke++) {
        var ox = random_range(-1.2, 1.2);
        var oy = random_range(-1.2, 1.2);
        draw_roundrect(
            hud_x - panel_padding + ox, 
            hud_y - panel_padding + oy, 
            hud_x + panel_width + random_range(-1, 1), 
            hud_y + panel_height + random_range(-1, 1), 
            true
        );
    }
    
    // Gold accent line (wobbly hand-drawn style) - thicker
    draw_set_color(make_color_rgb(255, 215, 0));
    for (var stroke = 0; stroke < 4; stroke++) {
        var ox = random_range(-0.8, 0.8);
        var oy = random_range(-0.8, 0.8);
        draw_line_width_color(
            hud_x - panel_padding + 4 + ox, 
            hud_y - panel_padding + 4 + oy,
            hud_x + panel_width - 4 + ox,
            hud_y - panel_padding + 4 + oy,
            2,
            make_color_rgb(255, 215, 0),
            make_color_rgb(255, 240, 150)
        );
        draw_line_width(
            hud_x + panel_width - 4 + ox,
            hud_y - panel_padding + 4 + oy,
            hud_x + panel_width - 4 + ox,
            hud_y + panel_height - 4 + oy,
            2
        );
        draw_line_width(
            hud_x + panel_width - 4 + ox,
            hud_y + panel_height - 4 + oy,
            hud_x - panel_padding + 4 + ox,
            hud_y + panel_height - 4 + oy,
            2
        );
        draw_line_width(
            hud_x - panel_padding + 4 + ox,
            hud_y + panel_height - 4 + oy,
            hud_x - panel_padding + 4 + ox,
            hud_y - panel_padding + 4 + oy,
            2
        );
    }
    
    random_set_seed(current_time);
    
    // Draw HUD text with outline
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(fnt_winkle); // Use hand-drawn font
    
    // Helper function for drawing hand-drawn outlined text with shadow
    function draw_hud_text(_x, _y, _text, _color, _outline_thickness, _scale) {
        // Draw soft shadow
        draw_set_alpha(0.3);
        draw_set_color(c_black);
        draw_text_transformed(_x + 3, _y + 3, _text, _scale, _scale, 0);
        draw_set_alpha(1);
        
        // Draw thick black outline
        draw_set_color(c_black);
        for (var ox = -_outline_thickness; ox <= _outline_thickness; ox++) {
            for (var oy = -_outline_thickness; oy <= _outline_thickness; oy++) {
                if (ox != 0 || oy != 0) {
                    draw_text_transformed(_x + ox, _y + oy, _text, _scale, _scale, 0);
                }
            }
        }
        // Draw main text
        draw_set_color(_color);
        draw_text_transformed(_x, _y, _text, _scale, _scale, 0);
        
        // Add highlight for depth
        draw_set_alpha(0.3);
        draw_set_color(c_white);
        draw_text_transformed(_x - 1, _y - 1, _text, _scale, _scale, 0);
        draw_set_alpha(1);
    }
    
    // SCORE with BIG hand-drawn style (with pulsing animation)
    var score_text = "SCORE: " + string(total_score);
    var base_scale = 1.8; // Much bigger base scale
    var animated_scale = base_scale + (sin(score_pulse) * 0.05); // Subtle breathing animation
    var final_scale = animated_scale * score_scale; // Apply both breathing and pulse
    
    // Draw hand-drawn star icon next to score
    var star_x = hud_x - 10;
    var star_y = hud_y + 18;
    var star_pulse_val = sin(score_pulse * 2) * 0.2;
    var star_scale = 1.4 + star_pulse_val;
    
    // Star with sketchy lines (hand-drawn)
    draw_set_color(make_color_rgb(255, 223, 0));
    var scrib_time = current_time * 0.008;
    for (var line = 0; line < 5; line++) {
        var angle = (line * 72) + sin(scrib_time + line) * 8;
        var dist1 = 10 * star_scale + sin(scrib_time * 2 + line) * 2;
        var dist2 = 14 * star_scale + sin(scrib_time * 3 + line) * 2;
        
        draw_line_width(
            star_x + lengthdir_x(dist1, angle - 90), 
            star_y + lengthdir_y(dist1, angle - 90),
            star_x + lengthdir_x(dist2, angle - 90), 
            star_y + lengthdir_y(dist2, angle - 90),
            2.5
        );
    }
    
    // Score text - hand-drawn style
    draw_hud_text(hud_x, hud_y, score_text, make_color_rgb(255, 215, 0), hud_outline_thickness, final_scale);
    
    // Decorative underline under score (wobbly hand-drawn)
    var underline_y = hud_y + 38;
    draw_set_color(make_color_rgb(255, 215, 0));
    random_set_seed(wobble_seed);
    for (var ux = hud_x; ux < hud_x + 200; ux += 4) {
        var wobble = random_range(-1.5, 1.5);
        draw_line_width(ux, underline_y + wobble, ux + 5, underline_y + random_range(-1.5, 1.5), 2.5);
    }
    random_set_seed(current_time);
    
    // STATS with hand-drawn icons (BIGGER)
    var icon_scale = 1.2;
    var text_scale = 1.3;
    
    // Completed orders - hand-drawn checkmark
    var completed_y = hud_y + line_height * 1.2;
    var check_x = hud_x - 12;
    var check_y = completed_y + 12;
    draw_set_color(make_color_rgb(100, 220, 100));
    // Wobbly checkmark
    random_set_seed(wobble_seed + 1);
    for (var w = 0; w < 2; w++) {
        draw_line_width(
            check_x - 5 + random_range(-0.5, 0.5), 
            check_y + random_range(-0.5, 0.5), 
            check_x + random_range(-0.5, 0.5), 
            check_y + 7 + random_range(-0.5, 0.5), 
            3.5
        );
        draw_line_width(
            check_x + random_range(-0.5, 0.5), 
            check_y + 7 + random_range(-0.5, 0.5), 
            check_x + 10 + random_range(-0.5, 0.5), 
            check_y - 7 + random_range(-0.5, 0.5), 
            3.5
        );
    }
    random_set_seed(current_time);
    
    draw_hud_text(hud_x, completed_y, "Completed: " + string(orders_completed), 
                  make_color_rgb(120, 255, 120), hud_outline_thickness, text_scale);
    
    // Failed orders - hand-drawn X mark
    var failed_y = hud_y + line_height * 2.2;
    var x_mark_x = hud_x - 12;
    var x_mark_y = failed_y + 12;
    draw_set_color(make_color_rgb(255, 100, 100));
    // Wobbly X
    random_set_seed(wobble_seed + 2);
    for (var w = 0; w < 2; w++) {
        draw_line_width(
            x_mark_x - 7 + random_range(-0.5, 0.5), 
            x_mark_y - 7 + random_range(-0.5, 0.5), 
            x_mark_x + 7 + random_range(-0.5, 0.5), 
            x_mark_y + 7 + random_range(-0.5, 0.5), 
            3.5
        );
        draw_line_width(
            x_mark_x - 7 + random_range(-0.5, 0.5), 
            x_mark_y + 7 + random_range(-0.5, 0.5), 
            x_mark_x + 7 + random_range(-0.5, 0.5), 
            x_mark_y - 7 + random_range(-0.5, 0.5), 
            3.5
        );
    }
    random_set_seed(current_time);
    
    draw_hud_text(hud_x, failed_y, "Failed: " + string(orders_failed), 
                  make_color_rgb(255, 120, 120), hud_outline_thickness, text_scale);
    
    // Active customers - hand-drawn person icon
    var active_customers = instance_number(OBJ_Customer);
    var customers_y = hud_y + line_height * 3.2;
    var person_x = hud_x - 12;
    var person_y = customers_y + 12;
    draw_set_color(make_color_rgb(100, 200, 255));
    // Wobbly person
    random_set_seed(wobble_seed + 3);
    for (var w = 0; w < 2; w++) {
        draw_circle(
            person_x + random_range(-0.3, 0.3), 
            person_y - 6 + random_range(-0.3, 0.3), 
            4.5, 
            true
        ); // Head outline
        draw_line_width(
            person_x + random_range(-0.3, 0.3), 
            person_y + random_range(-0.3, 0.3), 
            person_x + random_range(-0.3, 0.3), 
            person_y + 10 + random_range(-0.3, 0.3), 
            3.5
        ); // Body
    }
    random_set_seed(current_time);
    
    draw_hud_text(hud_x, customers_y, "Customers: " + string(active_customers), 
                  make_color_rgb(120, 220, 255), hud_outline_thickness, text_scale);
    
    // Hand-drawn sparkles/stars around panel corners
    var sparkle_time = score_pulse * 2;
    for (var i = 0; i < 4; i++) {
        var corner_angle = i * 90;
        var sparkle_offset = (i * 90) + sparkle_time;
        var corner_x = hud_x + (i % 2) * panel_width + (i < 2 ? -panel_padding : 0);
        var corner_y = hud_y + floor(i / 2) * panel_height + (i % 2 == 0 ? -panel_padding : 0);
        
        var sparkle_x = corner_x + sin(sparkle_offset) * 8;
        var sparkle_y = corner_y + cos(sparkle_offset * 1.3) * 8;
        var sparkle_alpha = (sin(sparkle_offset * 2) + 1) / 2 * 0.7;
        
        draw_set_alpha(sparkle_alpha);
        draw_set_color(make_color_rgb(255, 240, 150));
        // Hand-drawn sparkle (multiple sketchy strokes)
        random_set_seed(wobble_seed + i + 10);
        for (var s = 0; s < 2; s++) {
            draw_line_width(
                sparkle_x - 5 + random_range(-0.5, 0.5), 
                sparkle_y + random_range(-0.5, 0.5), 
                sparkle_x + 5 + random_range(-0.5, 0.5), 
                sparkle_y + random_range(-0.5, 0.5), 
                2
            );
            draw_line_width(
                sparkle_x + random_range(-0.5, 0.5), 
                sparkle_y - 5 + random_range(-0.5, 0.5), 
                sparkle_x + random_range(-0.5, 0.5), 
                sparkle_y + 5 + random_range(-0.5, 0.5), 
                2
            );
        }
        random_set_seed(current_time);
    }
    
    // Reset drawing settings
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_font(-1);
}
