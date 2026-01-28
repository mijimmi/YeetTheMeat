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
    // === NORMAL IN-GAME HUD ===
    var cam = view_camera[0];
    var cam_width = camera_get_view_width(cam);
    var cam_height = camera_get_view_height(cam);
    
    // HUD positioning - ADJUST HERE for HUD position
    var hud_x = 20;           // Distance from left edge
    var hud_y = 20;           // Distance from top edge
    var line_height = 30;     // Space between HUD lines
    
    // HUD OUTLINE SETTINGS
    var hud_outline_thickness = 2;  // Thickness for HUD text outline
    
    // Draw background panel
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_roundrect(hud_x - 10, hud_y - 10, hud_x + 300, hud_y + 130, false);
    draw_set_alpha(1);
    
    // Draw HUD text with outline
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // SIMPLER APPROACH: Draw outline directly without function
    // This avoids scope issues with local functions
    
    // Score with outline
    draw_set_color(c_black);
    for (var ox = -hud_outline_thickness; ox <= hud_outline_thickness; ox++) {
        for (var oy = -hud_outline_thickness; oy <= hud_outline_thickness; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text(hud_x + ox, hud_y + oy, "Score: " + string(total_score));
            }
        }
    }
    draw_set_color(c_white);
    draw_text(hud_x, hud_y, "Score: " + string(total_score));
    
    // Orders Completed with outline
    draw_set_color(c_black);
    for (var ox = -hud_outline_thickness; ox <= hud_outline_thickness; ox++) {
        for (var oy = -hud_outline_thickness; oy <= hud_outline_thickness; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text(hud_x + ox, hud_y + line_height + oy, "Orders Completed: " + string(orders_completed));
            }
        }
    }
    draw_set_color(c_white);
    draw_text(hud_x, hud_y + line_height, "Orders Completed: " + string(orders_completed));
    
    // Orders Failed with outline
    draw_set_color(c_black);
    for (var ox = -hud_outline_thickness; ox <= hud_outline_thickness; ox++) {
        for (var oy = -hud_outline_thickness; oy <= hud_outline_thickness; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text(hud_x + ox, hud_y + line_height * 2 + oy, "Orders Failed: " + string(orders_failed));
            }
        }
    }
    draw_set_color(c_white);
    draw_text(hud_x, hud_y + line_height * 2, "Orders Failed: " + string(orders_failed));
    
    // Customers with outline
    var active_customers = instance_number(OBJ_Customer);
    draw_set_color(c_black);
    for (var ox = -hud_outline_thickness; ox <= hud_outline_thickness; ox++) {
        for (var oy = -hud_outline_thickness; oy <= hud_outline_thickness; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text(hud_x + ox, hud_y + line_height * 3 + oy, "Customers: " + string(active_customers));
            }
        }
    }
    draw_set_color(c_white);
    draw_text(hud_x, hud_y + line_height * 3, "Customers: " + string(active_customers));
    
    // Reset drawing settings
    draw_set_color(c_white);
    draw_set_alpha(1);
}