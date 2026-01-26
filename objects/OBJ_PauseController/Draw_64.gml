// Draw GUI Event
if (paused) {
    var gui_width = display_get_gui_width();
    var gui_height = display_get_gui_height();
    var center_x = gui_width / 2;
    var center_y = gui_height / 2;
    
    // Draw darkened overlay
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gui_width, gui_height, false);
    draw_set_alpha(1);
    
    // Draw spr_pause centered on screen with slide animation (sprite origin is middle center)
    if (sprite_exists(spr_pause)) {
        draw_sprite_ext(spr_pause, 0, center_x, center_y + pause_anim_y, 1, 1, 0, c_white, pause_anim_alpha);
    }
    
    // Draw buttons with fnt_winkle (apply slide animation)
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(pause_anim_alpha);
    
    var text_scale = 6.0;
    var text_scale_selected = 6.5;
    
    // Apply Y offset to button positions
    var anim_offset = pause_anim_y;
    
    // Function to draw text with per-letter wave animation
    var letter_spacing = 45;  // Space between letters
    
    // Resume button
    var resume_selected = (selected_button == 0);
    var resume_text = "RESUME";
    var resume_y = center_y - 120 + anim_offset;
    var resume_len = string_length(resume_text);
    var resume_start_x = center_x - ((resume_len - 1) * letter_spacing) / 2;
    
    if (resume_selected) {
        // Per-letter wave animation
        draw_set_color(c_yellow);
        for (var i = 0; i < resume_len; i++) {
            var letter = string_char_at(resume_text, i + 1);
            var wave_offset = sin((current_time * 0.008) + (i * 0.8)) * 8;
            var scale_pulse = text_scale_selected + sin((current_time * 0.006) + (i * 0.5)) * 0.2;
            draw_text_transformed(resume_start_x + (i * letter_spacing), resume_y + wave_offset, letter, scale_pulse, scale_pulse, 0);
        }
    } else {
        // Black outline (thick)
        draw_set_color(c_black);
        for (var i = 0; i < resume_len; i++) {
            var letter = string_char_at(resume_text, i + 1);
            var lx = resume_start_x + (i * letter_spacing);
            // Draw outline in all 8 directions with multiple layers
            for (var ox = -4; ox <= 4; ox += 2) {
                for (var oy = -4; oy <= 4; oy += 2) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(lx + ox, resume_y + oy, letter, text_scale, text_scale, 0);
                    }
                }
            }
        }
        // White text
        draw_set_color(c_white);
        for (var i = 0; i < resume_len; i++) {
            var letter = string_char_at(resume_text, i + 1);
            draw_text_transformed(resume_start_x + (i * letter_spacing), resume_y, letter, text_scale, text_scale, 0);
        }
    }
    
    // Restart button
    var restart_selected = (selected_button == 1);
    var restart_text = "RESTART";
    var restart_y = center_y + 80 + anim_offset;
    var restart_len = string_length(restart_text);
    var restart_start_x = center_x - ((restart_len - 1) * letter_spacing) / 2;
    
    if (restart_selected) {
        // Per-letter wave animation
        draw_set_color(c_yellow);
        for (var i = 0; i < restart_len; i++) {
            var letter = string_char_at(restart_text, i + 1);
            var wave_offset = sin((current_time * 0.008) + (i * 0.8)) * 8;
            var scale_pulse = text_scale_selected + sin((current_time * 0.006) + (i * 0.5)) * 0.2;
            draw_text_transformed(restart_start_x + (i * letter_spacing), restart_y + wave_offset, letter, scale_pulse, scale_pulse, 0);
        }
    } else {
        // Black outline (thick)
        draw_set_color(c_black);
        for (var i = 0; i < restart_len; i++) {
            var letter = string_char_at(restart_text, i + 1);
            var lx = restart_start_x + (i * letter_spacing);
            // Draw outline in all 8 directions with multiple layers
            for (var ox = -4; ox <= 4; ox += 2) {
                for (var oy = -4; oy <= 4; oy += 2) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(lx + ox, restart_y + oy, letter, text_scale, text_scale, 0);
                    }
                }
            }
        }
        // White text
        draw_set_color(c_white);
        for (var i = 0; i < restart_len; i++) {
            var letter = string_char_at(restart_text, i + 1);
            draw_text_transformed(restart_start_x + (i * letter_spacing), restart_y, letter, text_scale, text_scale, 0);
        }
    }
    
    // Exit button (lower right)
    var exit_selected = (selected_button == 2);
    var exit_text = "EXIT";
    var exit_x = gui_width - 120;
    var exit_y = gui_height - 60 + anim_offset;
    var exit_scale = 3.5;
    var exit_scale_selected = 4.0;
    var exit_len = string_length(exit_text);
    var exit_letter_spacing = 30;
    var exit_start_x = exit_x - ((exit_len - 1) * exit_letter_spacing) / 2;
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    if (exit_selected) {
        // Per-letter wave animation in red
        draw_set_color(c_red);
        for (var i = 0; i < exit_len; i++) {
            var letter = string_char_at(exit_text, i + 1);
            var wave_offset = sin((current_time * 0.008) + (i * 0.8)) * 5;
            var scale_pulse = exit_scale_selected + sin((current_time * 0.006) + (i * 0.5)) * 0.15;
            draw_text_transformed(exit_start_x + (i * exit_letter_spacing), exit_y + wave_offset, letter, scale_pulse, scale_pulse, 0);
        }
    } else {
        // Black outline (thick)
        draw_set_color(c_black);
        for (var i = 0; i < exit_len; i++) {
            var letter = string_char_at(exit_text, i + 1);
            var lx = exit_start_x + (i * exit_letter_spacing);
            for (var ox = -3; ox <= 3; ox += 2) {
                for (var oy = -3; oy <= 3; oy += 2) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(lx + ox, exit_y + oy, letter, exit_scale, exit_scale, 0);
                    }
                }
            }
        }
        // White text
        draw_set_color(c_white);
        for (var i = 0; i < exit_len; i++) {
            var letter = string_char_at(exit_text, i + 1);
            draw_text_transformed(exit_start_x + (i * exit_letter_spacing), exit_y, letter, exit_scale, exit_scale, 0);
        }
    }
    
    // Reset draw settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}