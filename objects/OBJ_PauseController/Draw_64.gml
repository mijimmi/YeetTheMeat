// Draw GUI Event
if (paused) {
    var gui_width = display_get_gui_width();
    var gui_height = display_get_gui_height();

    // Draw darkened overlay
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gui_width, gui_height, false);
    draw_set_alpha(1);

    // === NEW LAYERED PAUSE MENU ===
    // Each PAUSE NEW sprite is a full 1920x1080 layer with a middle-center
    // origin, so they're all drawn at the screen centre (scaled to fill the GUI)
    // and simply stacked back-to-front to compose the menu. Animations come
    // later, so for now the whole stack just shares the existing slide-in
    // (pause_anim_y) and fade (pause_anim_alpha).
    var center_x = gui_width / 2;
    var center_y = gui_height / 2;
    var sw = sprite_get_width(spr_pausebg);
    var sh = sprite_get_height(spr_pausebg);
    var sxr = gui_width / sw;
    var syr = gui_height / sh;
    var slide_dy = pause_anim_y;    // whole-stack slide (used when sliding back out)
    var base_a   = pause_anim_alpha;
    var over = 1.04;                // tiny overscale so wobble never shows screen edges
    var t = current_time;
    var entering = !unpausing;      // staggered entrance vs. unpause slide-down

    // === STAGGERED ENTRANCE ===
    // Cutting board (bg) drops in first, then BOTH hands rise from the bottom together, the
    // title banner falls from the top, and the icons pop in last. Each uses a
    // smoothstep on its own slice of pause_timer.
    var p_bg   = clamp((pause_timer -  0) / 14, 0, 1); p_bg   = p_bg   * p_bg   * (3 - 2 * p_bg);
    var p_top  = clamp((pause_timer -  6) / 16, 0, 1); p_top  = p_top  * p_top  * (3 - 2 * p_top);
    var p_hand = clamp((pause_timer - 16) / 14, 0, 1); p_hand = p_hand * p_hand * (3 - 2 * p_hand);
    var p_icon = clamp((pause_timer - 24) / 12, 0, 1); p_icon = p_icon * p_icon * (3 - 2 * p_icon);

    // --- CUTTING BOARD (background) --- rises in first
    if (sprite_exists(spr_pausebg)) {
        var bg_y = entering ? (1 - p_bg) * 150 : slide_dy;
        var bg_a = entering ? p_bg : base_a;
        var bg_breath = 1 + sin(t * 0.0015) * 0.004;
        draw_sprite_ext(spr_pausebg, 0,
            center_x + sin(t * 0.0016) * 2, center_y + bg_y + cos(t * 0.0019) * 2,
            sxr * over * bg_breath, syr * over * bg_breath, sin(t * 0.0014) * 0.4, c_white, bg_a);
    }

    // --- TITLE BANNER --- falls from the top, then pulses big/small with a wobble
    if (sprite_exists(spr_pausetop)) {
        var top_y = entering ? (-(1 - p_top) * 340) : slide_dy;
        var top_a = entering ? p_top : base_a;
        var top_pulse = 1 + sin(t * 0.004) * 0.03;     // subtle grow/shrink
        var top_rot   = sin(t * 0.0023) * 0.5;         // gentle wobble
        draw_sprite_ext(spr_pausetop, 0,
            center_x + sin(t * 0.0026) * 1.2, center_y + top_y,
            sxr * over * top_pulse, syr * over * top_pulse, top_rot, c_white, top_a);
    }

    // --- LEFT HAND --- rises in from the bottom (with the right hand)
    if (sprite_exists(spr_pauseleft)) {
        var lh_y = entering ? ((1 - p_hand) * 280) : slide_dy;
        var lh_a = entering ? p_hand : base_a;
        var lh_breath = 1 + sin(t * 0.0017 + 1) * 0.005;
        draw_sprite_ext(spr_pauseleft, 0,
            center_x + sin(t * 0.0018 + 1) * 2, center_y + lh_y + cos(t * 0.0021 + 1) * 2,
            sxr * over * lh_breath, syr * over * lh_breath, sin(t * 0.0016 + 1) * 0.6, c_white, lh_a);
    }

    // --- RIGHT HAND --- rises in from the bottom (slightly wobblier)
    if (sprite_exists(spr_pauseright)) {
        var rh_y = entering ? ((1 - p_hand) * 280) : slide_dy;
        var rh_a = entering ? p_hand : base_a;
        var rh_breath = 1 + sin(t * 0.0023 + 2) * 0.009;
        draw_sprite_ext(spr_pauseright, 0,
            center_x + sin(t * 0.0024 + 2) * 4, center_y + rh_y + cos(t * 0.0028 + 2) * 4,
            sxr * over * rh_breath, syr * over * rh_breath, sin(t * 0.0026 + 2) * 1.4, c_white, rh_a);
    }

    // Slice progress: blade crosses the centre around frame 8, after which the
    // chosen icon splits into two halves that slide apart, drop and fade.
    var slice_blade = clamp(slice_timer / 16, 0, 1);
    var slice_split = clamp((slice_timer - 8) / (slice_duration - 8), 0, 1);
    var split_px = slice_split * 160;
    var fall_px  = slice_split * slice_split * 260;
    var half_fade = 1 - max(0, (slice_split - 0.55) / 0.45);

    // --- PLAY (RESUME) ICON --- pops in last, enlarges while RESUME is selected
    if (sprite_exists(spr_pauseplayicon)) {
        var play_target = (selected_button == 0) ? 1.18 : 1.0;
        play_icon_scale = lerp(play_icon_scale, play_target, 0.2);
        var pi_y = entering ? 0 : slide_dy;
        var pi_a = entering ? p_icon : base_a;
        var pi_s = play_icon_scale * (1 + sin(t * 0.005) * 0.02);
        if (slice_active && slice_kind == 0 && slice_timer >= 8) {
            draw_sliced_icon(spr_pauseplayicon, sxr * over * pi_s, syr * over * pi_s,
                split_px, fall_px, pi_a * half_fade);
        } else {
            draw_sprite_ext(spr_pauseplayicon, 0, center_x, center_y + pi_y,
                sxr * over * pi_s, syr * over * pi_s, 0, c_white, pi_a);
        }
    }

    // --- RESTART ICON --- pops in last, enlarges while RESTART is selected
    if (sprite_exists(spr_pauserestarticon)) {
        var restart_target = (selected_button == 1) ? 1.18 : 1.0;
        restart_icon_scale = lerp(restart_icon_scale, restart_target, 0.2);
        var ri_y = entering ? 0 : slide_dy;
        var ri_a = entering ? p_icon : base_a;
        var ri_s = restart_icon_scale * (1 + sin(t * 0.005 + 1) * 0.02);
        if (slice_active && slice_kind == 1 && slice_timer >= 8) {
            draw_sliced_icon(spr_pauserestarticon, sxr * over * ri_s, syr * over * ri_s,
                split_px, fall_px, ri_a * half_fade);
        } else {
            draw_sprite_ext(spr_pauserestarticon, 0, center_x, center_y + ri_y,
                sxr * over * ri_s, syr * over * ri_s, 0, c_white, ri_a);
        }
    }

    // --- BLADE SWEEP --- a big, bright CURVED crescent slash that arcs across
    // the screen (built from short segments with rounded joints so it bends
    // smoothly).
    if (slice_active && slice_timer <= 18) {
        var sweep_x = lerp(-gui_width * 0.45, gui_width * 1.45, slice_blade);
        var segs   = 26;
        var bow    = gui_width * 0.22;   // sideways bulge -> crescent curve
        var spread = gui_width * 0.55;   // diagonal lean top-to-bottom
        var pass_w = [130, 60, 22];
        var pass_c = [make_color_rgb(255, 240, 190), make_color_rgb(255, 250, 225), c_white];
        var pass_a = [0.18, 0.45, 1.0];
        for (var p = 0; p < 3; p++) {
            draw_set_color(pass_c[p]);
            draw_set_alpha(pass_a[p]);
            var pw = pass_w[p];
            var prev_x = 0, prev_y = 0;
            for (var i = 0; i <= segs; i++) {
                var u  = i / segs;
                var py = lerp(-150, gui_height + 150, u);
                var px = sweep_x + (u - 0.5) * spread + sin(u * pi) * bow;
                if (i > 0) {
                    draw_line_width(prev_x, prev_y, px, py, pw);
                }
                draw_circle(px, py, pw / 2, false);  // round the joints
                prev_x = px;
                prev_y = py;
            }
        }
        draw_set_alpha(1);
    }

    // Draw buttons with fnt_winkle (apply slide animation) - SAME AS OLD MENU
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
        // Per-letter wave animation with a thick black outline so it stays
        // readable against the light cutting board (no more washed-out yellow).
        for (var i = 0; i < resume_len; i++) {
            var letter = string_char_at(resume_text, i + 1);
            var lx = resume_start_x + (i * letter_spacing);
            var wave_offset = sin((current_time * 0.008) + (i * 0.8)) * 8;
            var scale_pulse = text_scale_selected + sin((current_time * 0.006) + (i * 0.5)) * 0.2;
            draw_set_color(c_black);
            for (var ox = -4; ox <= 4; ox += 2) {
                for (var oy = -4; oy <= 4; oy += 2) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(lx + ox, resume_y + wave_offset + oy, letter, scale_pulse, scale_pulse, 0);
                    }
                }
            }
            draw_set_color(make_color_rgb(255, 150, 45));
            draw_text_transformed(lx, resume_y + wave_offset, letter, scale_pulse, scale_pulse, 0);
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
        // Per-letter wave animation with a thick black outline for readability
        for (var i = 0; i < restart_len; i++) {
            var letter = string_char_at(restart_text, i + 1);
            var lx = restart_start_x + (i * letter_spacing);
            var wave_offset = sin((current_time * 0.008) + (i * 0.8)) * 8;
            var scale_pulse = text_scale_selected + sin((current_time * 0.006) + (i * 0.5)) * 0.2;
            draw_set_color(c_black);
            for (var ox = -4; ox <= 4; ox += 2) {
                for (var oy = -4; oy <= 4; oy += 2) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(lx + ox, restart_y + wave_offset + oy, letter, scale_pulse, scale_pulse, 0);
                    }
                }
            }
            draw_set_color(make_color_rgb(255, 150, 45));
            draw_text_transformed(lx, restart_y + wave_offset, letter, scale_pulse, scale_pulse, 0);
        }
    } else {
        // Black outline (thick)
        draw_set_color(c_black);
        for (var i = 0; i < restart_len; i++) {
            var letter = string_char_at(restart_text, i + 1);
            var lx = restart_start_x + (i * letter_spacing);
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

    // Menu button (lower right, above exit)
    var menu_selected = (selected_button == 2);
    var menu_text = "MENU";
    var menu_x = gui_width - 120;
    var menu_y = gui_height - 120 + anim_offset;
    var menu_scale = 3.5;
    var menu_scale_selected = 4.0;
    var menu_len = string_length(menu_text);
    var menu_letter_spacing = 30;
    var menu_start_x = menu_x - ((menu_len - 1) * menu_letter_spacing) / 2;

    if (menu_selected) {
        // Per-letter wave animation in orange
        draw_set_color(c_orange);
        for (var i = 0; i < menu_len; i++) {
            var letter = string_char_at(menu_text, i + 1);
            var wave_offset = sin((current_time * 0.008) + (i * 0.8)) * 5;
            var scale_pulse = menu_scale_selected + sin((current_time * 0.006) + (i * 0.5)) * 0.15;
            draw_text_transformed(menu_start_x + (i * menu_letter_spacing), menu_y + wave_offset, letter, scale_pulse, scale_pulse, 0);
        }
    } else {
        // Black outline (thick)
        draw_set_color(c_black);
        for (var i = 0; i < menu_len; i++) {
            var letter = string_char_at(menu_text, i + 1);
            var lx = menu_start_x + (i * menu_letter_spacing);
            for (var ox = -3; ox <= 3; ox += 2) {
                for (var oy = -3; oy <= 3; oy += 2) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(lx + ox, menu_y + oy, letter, menu_scale, menu_scale, 0);
                    }
                }
            }
        }
        // White text
        draw_set_color(c_white);
        for (var i = 0; i < menu_len; i++) {
            var letter = string_char_at(menu_text, i + 1);
            draw_text_transformed(menu_start_x + (i * menu_letter_spacing), menu_y, letter, menu_scale, menu_scale, 0);
        }
    }

    // Exit button (lower right, below menu)
    var exit_selected = (selected_button == 3);
    var exit_text = "EXIT";
    var exit_x = gui_width - 120;
    var exit_y = gui_height - 50 + anim_offset;
    var exit_scale = 3.5;
    var exit_scale_selected = 4.0;
    var exit_len = string_length(exit_text);
    var exit_letter_spacing = 30;
    var exit_start_x = exit_x - ((exit_len - 1) * exit_letter_spacing) / 2;

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
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
}