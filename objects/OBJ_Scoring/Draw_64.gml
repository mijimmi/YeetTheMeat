// OBJ_Scoring Draw GUI Event
// NOTE: Text size controlled by scale parameters in draw_text_transformed()
//       Adjust font_size variable below to change text size globally

// Don't draw score HUD or scoreboard during tutorial
if (instance_exists(OBJ_TutorialManager) || room == tutorial_room) {
    exit;
}

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
    
    // Instructions with outline
    if (!entering_name) {
        draw_outlined_text(text_x, text_y + restart_offset, "Press X to Restart", font_size, font_size, tilt_angle, outline_thickness);
        draw_outlined_text(text_x, text_y + restart_offset + line_spacing, "Press B for Menu", font_size, font_size, tilt_angle, outline_thickness);
    }
    
    // Now draw white text on top (centered)
    draw_set_color(c_white);
    
    // Draw all text with 3x size, left tilt (-15), and consistent spacing
    draw_text_transformed(text_x, text_y - title_offset, "RUN COMPLETE!", font_size, font_size, tilt_angle);
    draw_text_transformed(text_x, text_y - (line_spacing * 1), "Final Score: " + string(total_score), font_size, font_size, tilt_angle);
    draw_text_transformed(text_x, text_y + (line_spacing * 0), "Orders Completed: " + string(orders_completed), font_size, font_size, tilt_angle);
    draw_text_transformed(text_x, text_y + (line_spacing * 1), "Orders Failed: " + string(orders_failed), font_size, font_size, tilt_angle);
    
    // Show instructions
    if (!entering_name) {
        draw_text_transformed(text_x, text_y + restart_offset, "Press X to Restart", font_size, font_size, tilt_angle);
        draw_text_transformed(text_x, text_y + restart_offset + line_spacing, "Press B for Menu", font_size, font_size, tilt_angle);
    }
    
    // Reset alignment
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // === NAME ENTRY AT BOTTOM (SEPARATE, BIG) ===
    if (entering_name) {
        var gui_w = display_get_gui_width();
        var gui_h = display_get_gui_height();
        var bottom_y = gui_h - 320; // Higher on screen
        var name_font_size = 4; // Bigger than score text
        var name_tilt = 0; // No tilt for name entry
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // "ENTER NAME:" title
        var title_text = "ENTER NAME:";
        
        // Black outline for title
        draw_set_color(c_black);
        for (var ox = -4; ox <= 4; ox++) {
            for (var oy = -4; oy <= 4; oy++) {
                if (ox != 0 || oy != 0) {
                    draw_text_transformed(gui_w / 2 + ox, bottom_y + oy, title_text, name_font_size * 0.7, name_font_size * 0.7, name_tilt);
                }
            }
        }
        
        // White title text
        draw_set_color(c_white);
        draw_text_transformed(gui_w / 2, bottom_y, title_text, name_font_size * 0.7, name_font_size * 0.7, name_tilt);
        
        // Draw letters with big spacing
        var letter_spacing = 120;
        var letters_y = bottom_y + 80;
        var start_x = (gui_w / 2) - letter_spacing;
        
        for (var i = 0; i < max_name_length; i++) {
            var letter = string_char_at(available_chars, char_index[i] + 1);
            var letter_x = start_x + (i * letter_spacing);
            
            // Black outline for letter
            draw_set_color(c_black);
            for (var ox = -5; ox <= 5; ox++) {
                for (var oy = -5; oy <= 5; oy++) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(letter_x + ox, letters_y + oy, letter, name_font_size, name_font_size, name_tilt);
                    }
                }
            }
            
            // Highlight current cursor position with yellow, otherwise white
            if (i == name_cursor) {
                draw_set_color(c_yellow);
            } else {
                draw_set_color(c_white);
            }
            draw_text_transformed(letter_x, letters_y, letter, name_font_size, name_font_size, name_tilt);
        }
        
        // Instructions
        var instructions = "D-Pad: Change  X: Confirm";
        draw_set_color(c_black);
        for (var ox = -2; ox <= 2; ox++) {
            for (var oy = -2; oy <= 2; oy++) {
                if (ox != 0 || oy != 0) {
                    draw_text_transformed(gui_w / 2 + ox, letters_y + 80 + oy, instructions, name_font_size * 0.5, name_font_size * 0.5, name_tilt);
                }
            }
        }
        draw_set_color(c_white);
        draw_text_transformed(gui_w / 2, letters_y + 80, instructions, name_font_size * 0.5, name_font_size * 0.5, name_tilt);
        
        // Reset alignment
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
else {
    // === IN-GAME HUD (clean recipe-card style) ===
    draw_set_font(fnt_winkle);

    var cream      = make_color_rgb(252, 244, 228);
    var brown      = make_color_rgb(110, 70, 40);
    var brown_soft = make_color_rgb(150, 105, 70);
    var gold       = make_color_rgb(245, 190, 70);
    var gold_lite  = make_color_rgb(255, 232, 170);

    // Filled star helper (clean, crisp - no jitter)
    function hud_star(_cx, _cy, _ro, _ri, _rot) {
        draw_primitive_begin(pr_trianglefan);
        draw_vertex(_cx, _cy);
        for (var i = 0; i <= 10; i++) {
            var ang = _rot + (i * 36);
            var r = (i % 2 == 0) ? _ro : _ri;
            draw_vertex(_cx + lengthdir_x(r, ang - 90), _cy + lengthdir_y(r, ang - 90));
        }
        draw_primitive_end();
    }

    // Outlined text helper for crisp readable rows
    function hud_label(_x, _y, _text, _color, _scale) {
        draw_set_color(c_black);
        for (var ox = -2; ox <= 2; ox += 2) {
            for (var oy = -2; oy <= 2; oy += 2) {
                if (ox != 0 || oy != 0) {
                    draw_text_transformed(_x + ox, _y + oy, _text, _scale, _scale, 0);
                }
            }
        }
        draw_set_color(_color);
        draw_text_transformed(_x, _y, _text, _scale, _scale, 0);
    }

    // Panel geometry (gentle idle bob)
    var bob     = sin(current_time / 650) * 2;
    var hud_x   = 28;
    var hud_y   = 26 + bob;
    var panel_w = 286;
    var panel_h = 244;
    var rad     = 22;
    var px1 = hud_x;
    var py1 = hud_y;
    var px2 = hud_x + panel_w;
    var py2 = hud_y + panel_h;

    // Drop shadow
    draw_set_alpha(0.25);
    draw_set_color(c_black);
    draw_roundrect_ext(px1 + 6, py1 + 8, px2 + 6, py2 + 8, rad, rad, false);

    // Card fill
    draw_set_alpha(0.92);
    draw_set_color(cream);
    draw_roundrect_ext(px1, py1, px2, py2, rad, rad, false);

    // Double border
    draw_set_alpha(1);
    draw_set_color(brown);
    draw_roundrect_ext(px1, py1, px2, py2, rad, rad, true);
    draw_roundrect_ext(px1 + 4, py1 + 4, px2 - 4, py2 - 4, rad - 4, rad - 4, true);

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);

    // --- SCORE header pill ---
    var pill_x1 = px1 + 14;
    var pill_x2 = px2 - 14;
    var pill_y1 = py1 + 14;
    var pill_y2 = pill_y1 + 78;
    draw_set_color(brown);
    draw_roundrect_ext(pill_x1, pill_y1, pill_x2, pill_y2, 16, 16, false);
    draw_set_color(gold);
    draw_roundrect_ext(pill_x1, pill_y1, pill_x2, pill_y2, 16, 16, true);

    // Star icon (gentle pulse)
    var star_cx = pill_x1 + 38;
    var star_cy = (pill_y1 + pill_y2) / 2;
    var star_pulse = 1.0 + sin(score_pulse * 2) * 0.08;
    draw_set_color(gold);
    hud_star(star_cx, star_cy, 20 * star_pulse, 9 * star_pulse, sin(score_pulse) * 6);
    draw_set_color(gold_lite);
    hud_star(star_cx, star_cy, 11 * star_pulse, 5 * star_pulse, sin(score_pulse) * 6);

    // SCORE label + big animated value
    draw_set_color(gold_lite);
    draw_text_transformed(pill_x1 + 72, pill_y1 + 22, "SCORE", 0.85, 0.85, 0);
    var val_scale = 2.0 * score_scale;
    draw_set_color(c_white);
    draw_text_transformed(pill_x1 + 72, pill_y1 + 50, string(total_score), val_scale, val_scale, 0);

    // --- Stat rows ---
    var row_scale = 1.25;
    var icon_x    = px1 + 38;
    var text_x    = px1 + 64;
    var row1_y    = pill_y2 + 32;
    var row_gap   = 46;

    var active_customers = instance_number(OBJ_Customer_Parent);

    // Completed (green check)
    var cy0 = row1_y;
    draw_set_color(make_color_rgb(70, 175, 80));
    draw_line_width(icon_x - 8, cy0, icon_x - 1, cy0 + 8, 4);
    draw_line_width(icon_x - 1, cy0 + 8, icon_x + 11, cy0 - 8, 4);
    hud_label(text_x, cy0, "Completed: " + string(orders_completed), make_color_rgb(120, 230, 130), row_scale);

    // Failed (red x)
    var cy1 = row1_y + row_gap;
    draw_set_color(make_color_rgb(205, 80, 70));
    draw_line_width(icon_x - 8, cy1 - 8, icon_x + 8, cy1 + 8, 4);
    draw_line_width(icon_x - 8, cy1 + 8, icon_x + 8, cy1 - 8, 4);
    hud_label(text_x, cy1, "Failed: " + string(orders_failed), make_color_rgb(255, 130, 120), row_scale);

    // Customers (blue person)
    var cy2 = row1_y + row_gap * 2;
    draw_set_color(make_color_rgb(70, 160, 230));
    draw_circle(icon_x, cy2 - 6, 5, false);
    draw_roundrect(icon_x - 7, cy2 + 1, icon_x + 7, cy2 + 11, false);
    hud_label(text_x, cy2, "Customers: " + string(active_customers), make_color_rgb(130, 205, 255), row_scale);

    // Reset drawing settings
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
}
