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
    
    // === Controller disclaimer at bottom ===
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var disclaimer_text = "This game is best played with a controller";
    var disclaimer_y = 1080 - 80;  // 80px from bottom
    var disclaimer_scale = 2;
    
    // Black outline
    draw_set_color(c_black);
    for (var ox = -2; ox <= 2; ox += 2) {
        for (var oy = -2; oy <= 2; oy += 2) {
            if (ox != 0 || oy != 0) {
                draw_text_transformed(cx + ox, disclaimer_y + oy, disclaimer_text, disclaimer_scale, disclaimer_scale, 0);
            }
        }
    }
    // Light gray text (subtle but readable)
    draw_set_color(make_color_rgb(200, 200, 200));
    draw_text_transformed(cx, disclaimer_y, disclaimer_text, disclaimer_scale, disclaimer_scale, 0);
    
    // Reset draw settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
// === LEADERBOARD ===
else if (menu_state == "leaderboard") {
    // Draw background
    draw_sprite(spr_menuBG3, 0, cx, cy);
    
    // Draw leaderboard paper (stationary, above background, below text)
    if (sprite_exists(spr_leaderboardpaper)) {
        draw_sprite(spr_leaderboardpaper, 0, cx, cy);
    }
    
    // Draw leaderboard paw (animated from bottom with bobbing, above paper, below text)
    if (sprite_exists(spr_leaderboardpaw)) {
        // Add bobbing effect once paw reaches target position
        var bob_offset = 0;
        if (leaderboard_paw_y <= leaderboard_paw_target_y) {
            bob_offset = sin(leaderboard_paw_bob_timer) * leaderboard_paw_bob_amount;
        }
        draw_sprite(spr_leaderboardpaw, 0, cx, leaderboard_paw_y + bob_offset);
    }
    
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Draw title "LEADERBOARD" with animation
    var title_text = "LEADERBOARD";
    var title_base_y = 150; // Lowered from 120 to 150
    var title_scale = 4;
    
    // Brown color for entry text (not title)
    var brown_color = make_color_rgb(101, 67, 33);
    
    // Title animation
    var title_y_offset = sin(leaderboard_title_timer * leaderboard_title_bob_speed) * leaderboard_title_bob_amount;
    var title_rotation = sin(leaderboard_title_timer * leaderboard_title_sway_speed) * leaderboard_title_sway_amount;
    var title_y = title_base_y + title_y_offset;
    
    // Black outline
    draw_set_color(c_black);
    for (var ox = -4; ox <= 4; ox += 4) {
        for (var oy = -4; oy <= 4; oy += 4) {
            if (ox != 0 || oy != 0) {
                draw_text_transformed(cx + ox, title_y + oy, title_text, title_scale, title_scale, title_rotation);
            }
        }
    }
    // White text
    draw_set_color(c_white);
    draw_text_transformed(cx, title_y, title_text, title_scale, title_scale, title_rotation);
    
    // Draw leaderboard entries
    var entry_start_y = 280; // Lowered from 250 to 280
    var entry_spacing = 65;
    var entry_scale = 2;
    var rank_x = cx - 300;
    var name_x = cx;
    var score_x = cx + 300;
    
    for (var i = 0; i < array_length(leaderboard_entries); i++) {
        var entry = leaderboard_entries[i];
        var entry_name = entry[0];
        var entry_score = string(entry[1]);
        var entry_y = entry_start_y + (i * entry_spacing);
        var rank_text = string(i + 1) + ".";
        
        // Brown color for all entries
        var entry_color = brown_color;
        
        // Draw rank
        draw_set_halign(fa_right);
        draw_set_color(c_black);
        draw_text_transformed(rank_x + 2, entry_y + 2, rank_text, entry_scale, entry_scale, 0);
        draw_set_color(entry_color);
        draw_text_transformed(rank_x, entry_y, rank_text, entry_scale, entry_scale, 0);
        
        // Draw name
        draw_set_halign(fa_center);
        draw_set_color(c_black);
        draw_text_transformed(name_x + 2, entry_y + 2, entry_name, entry_scale, entry_scale, 0);
        draw_set_color(entry_color);
        draw_text_transformed(name_x, entry_y, entry_name, entry_scale, entry_scale, 0);
        
        // Draw score
        draw_set_halign(fa_left);
        draw_set_color(c_black);
        draw_text_transformed(score_x + 2, entry_y + 2, entry_score, entry_scale, entry_scale, 0);
        draw_set_color(entry_color);
        draw_text_transformed(score_x, entry_y, entry_score, entry_scale, entry_scale, 0);
    }
    
    // Draw Go Back button (with limited scale)
    var back_scale = 1 + (leaderboard_back_scale - 1) * 0.3;
    
    // Draw outline (always shown since it's the only button)
    for (var ox = -outline_thickness; ox <= outline_thickness; ox += outline_thickness) {
        for (var oy = -outline_thickness; oy <= outline_thickness; oy += outline_thickness) {
            if (ox != 0 || oy != 0) {
                draw_sprite_ext(spr_goback, 0, cx + ox, cy + oy, back_scale, back_scale, 0, outline_color, 1);
            }
        }
    }
    draw_sprite_ext(spr_goback, 0, cx, cy, back_scale, back_scale, 0, c_white, 1);
    
    // Reset draw settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// === NOW PLAYING (Top Right Corner - Shows on all menu states) ===
draw_set_font(fnt_winkle);
draw_set_halign(fa_right);
draw_set_valign(fa_top);

var now_playing_x = 1920 - 30; // 30px from right edge
var now_playing_y = 30; // 30px from top
var text_scale = 1.2;
var line_spacing = 25;

// "Now Playing" label
draw_set_color(c_black);
draw_text_transformed(now_playing_x + 1, now_playing_y + 1, "Now Playing:", text_scale, text_scale, 0);
draw_set_color(make_color_rgb(255, 200, 100)); // Light orange/yellow
draw_text_transformed(now_playing_x, now_playing_y, "Now Playing:", text_scale, text_scale, 0);

// Song title
draw_set_color(c_black);
draw_text_transformed(now_playing_x + 1, now_playing_y + line_spacing + 1, song_title, text_scale * 0.9, text_scale * 0.9, 0);
draw_set_color(c_white);
draw_text_transformed(now_playing_x, now_playing_y + line_spacing, song_title, text_scale * 0.9, text_scale * 0.9, 0);

// Artist credit
draw_set_color(c_black);
draw_text_transformed(now_playing_x + 1, now_playing_y + line_spacing * 2 + 1, "by " + song_artist, text_scale * 0.75, text_scale * 0.75, 0);
draw_set_color(make_color_rgb(180, 180, 180)); // Light gray
draw_text_transformed(now_playing_x, now_playing_y + line_spacing * 2, "by " + song_artist, text_scale * 0.75, text_scale * 0.75, 0);

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);