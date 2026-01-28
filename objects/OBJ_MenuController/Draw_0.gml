// === DRAW MENU ===

// Screen center
var cx = 960;  // 1920 / 2
var cy = 540;  // 1080 / 2

// === MAIN MENU ===
if (menu_state == "main") {
    // Draw background
    draw_sprite(spr_menubg, 0, cx, cy);
    
    // Draw title with fluid multi-layered animation
    // Combine multiple sine waves at different speeds for organic motion
    var title_y_offset = sin(title_time * title_float_speed) * title_float_amount 
                       + sin(title_time * title_bob_speed) * title_bob_amount;
    var title_x_offset = sin(title_time * title_drift_speed) * title_drift_amount;
    var title_rotation = sin(title_time * title_sway_speed) * title_sway_amount;
    var title_scale = 1 + sin(title_time * title_breathe_speed) * title_breathe_amount;
    
    draw_sprite_ext(spr_title, 0, cx + title_x_offset, cy + title_y_offset, title_scale, title_scale, title_rotation, c_white, 1);
    
    // Draw buttons
    var button_sprites = [spr_start, spr_leaderboard, spr_exit];
    
    for (var i = 0; i < total_buttons; i++) {
        var btn_sprite = button_sprites[i];
        var btn_scale = button_scales[i];
        
        // Draw outline if selected
        if (i == selected_button) {
            for (var ox = -outline_thickness; ox <= outline_thickness; ox += outline_thickness) {
                for (var oy = -outline_thickness; oy <= outline_thickness; oy += outline_thickness) {
                    if (ox != 0 || oy != 0) {
                        draw_sprite_ext(btn_sprite, 0, cx + ox, cy + oy, btn_scale, btn_scale, 0, outline_color, 1);
                    }
                }
            }
        }
        
        // Draw the button
        draw_sprite_ext(btn_sprite, 0, cx, cy, btn_scale, btn_scale, 0, c_white, 1);
    }
}
// === MODE SELECT MENU ===
else if (menu_state == "mode_select") {
    // Draw background
    draw_sprite(spr_menuBG2, 0, cx, cy);
    
    // Draw mode text at top
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    
    var mode_text = "";
    if (selected_mode == 0) {
        mode_text = "Play Singleplayer";
    } else if (selected_mode == 1) {
        mode_text = "Play Multiplayer";
    } else {
        mode_text = "Go Back";
    }
    
    // Draw text with outline (bigger text)
    var text_x = cx;
    var text_y = 150;
    var text_scale = 4;
    
    // Black outline
    draw_set_color(c_black);
    for (var ox = -3; ox <= 3; ox += 3) {
        for (var oy = -3; oy <= 3; oy += 3) {
            if (ox != 0 || oy != 0) {
                draw_text_transformed(text_x + ox, text_y + oy, mode_text, text_scale, text_scale, 0);
            }
        }
    }
    // White text
    draw_set_color(c_white);
    draw_text_transformed(text_x, text_y, mode_text, text_scale, text_scale, 0);
    
    // === Draw Singleplayer button (left - scales towards center/right) ===
    var sp_scale = mode_button_scales[0];
    // Offset towards center when scaling up
    var sp_offset = (sp_scale - 1) * 150;  // Move right when bigger
    var sp_x = cx + sp_offset;
    var sp_y = cy;
    
    if (selected_mode == 0) {
        // Draw outline
        for (var ox = -outline_thickness; ox <= outline_thickness; ox += outline_thickness) {
            for (var oy = -outline_thickness; oy <= outline_thickness; oy += outline_thickness) {
                if (ox != 0 || oy != 0) {
                    draw_sprite_ext(spr_singleplayer, 0, sp_x + ox, sp_y + oy, sp_scale, sp_scale, 0, outline_color, 1);
                }
            }
        }
    }
    draw_sprite_ext(spr_singleplayer, 0, sp_x, sp_y, sp_scale, sp_scale, 0, c_white, 1);
    
    // === Draw Multiplayer button (right - scales towards center/left) ===
    var mp_scale = mode_button_scales[1];
    // Offset towards center when scaling up
    var mp_offset = (mp_scale - 1) * -150;  // Move left when bigger
    var mp_x = cx + mp_offset;
    var mp_y = cy;
    
    if (selected_mode == 1) {
        // Draw outline
        for (var ox = -outline_thickness; ox <= outline_thickness; ox += outline_thickness) {
            for (var oy = -outline_thickness; oy <= outline_thickness; oy += outline_thickness) {
                if (ox != 0 || oy != 0) {
                    draw_sprite_ext(spr_multiplayer, 0, mp_x + ox, mp_y + oy, mp_scale, mp_scale, 0, outline_color, 1);
                }
            }
        }
    }
    draw_sprite_ext(spr_multiplayer, 0, mp_x, mp_y, mp_scale, mp_scale, 0, c_white, 1);
    
    // === Draw Go Back button (full screen sprite - smaller scale to avoid going off screen) ===
    // Limit the scale growth for this button since it's large
    var back_scale_raw = mode_button_scales[2];
    var back_scale = 1 + (back_scale_raw - 1) * 0.3;  // Only 30% of the scale effect
    
    if (selected_mode == 2) {
        // Draw outline
        for (var ox = -outline_thickness; ox <= outline_thickness; ox += outline_thickness) {
            for (var oy = -outline_thickness; oy <= outline_thickness; oy += outline_thickness) {
                if (ox != 0 || oy != 0) {
                    draw_sprite_ext(spr_goback, 0, cx + ox, cy + oy, back_scale, back_scale, 0, outline_color, 1);
                }
            }
        }
    }
    draw_sprite_ext(spr_goback, 0, cx, cy, back_scale, back_scale, 0, c_white, 1);
    
    // Reset draw settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
