// === DRAW CONTROLLER DISCONNECT WARNING ===
// Only shows for P1 - P2 can use keyboard as fallback
if (global.controller_disconnected) {
    var gui_width = display_get_gui_width();
    var gui_height = display_get_gui_height();
    
    // Darken the screen
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gui_width, gui_height, false);
    draw_set_alpha(1);
    
    // Pulsing effect
    var pulse = 0.8 + sin(disconnect_pulse_timer) * 0.2;
    var text_scale = 3.0 * pulse;
    
    var disconnect_text = "P1 DISCONNECTED";
    
    var center_x = gui_width / 2;
    var center_y = gui_height / 2 - 40;
    
    // Draw main text with thick black outline
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Black outline (draw in multiple directions)
    draw_set_color(c_black);
    var outline_size = 4;
    for (var ox = -outline_size; ox <= outline_size; ox++) {
        for (var oy = -outline_size; oy <= outline_size; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text_transformed(center_x + ox, center_y + oy, disconnect_text, text_scale, text_scale, 0);
            }
        }
    }
    
    // Main text in red for P1
    draw_set_color(c_red);
    draw_text_transformed(center_x, center_y, disconnect_text, text_scale, text_scale, 0);
    
    // Sub-text instruction
    var sub_text = "Reconnect controller to continue";
    var sub_scale = 1.5;
    var sub_y = center_y + 80;
    
    // Black outline for sub-text
    draw_set_color(c_black);
    for (var ox = -2; ox <= 2; ox++) {
        for (var oy = -2; oy <= 2; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text_transformed(center_x + ox, sub_y + oy, sub_text, sub_scale, sub_scale, 0);
            }
        }
    }
    
    // White sub-text
    draw_set_color(c_white);
    draw_text_transformed(center_x, sub_y, sub_text, sub_scale, sub_scale, 0);
    
    // Reset draw settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// === NOW PLAYING (Top Right Corner - Shows during gameplay only) ===
// Don't show during cutscene, tutorial, or results screen
var results_showing = (instance_exists(OBJ_Scoring) && OBJ_Scoring.show_results);
if (!instance_exists(OBJ_CutsceneController) && !instance_exists(OBJ_TutorialManager) && !results_showing) {
    draw_set_font(global.game_font);
    draw_set_halign(fa_right);
    draw_set_valign(fa_top);

    var gui_w = display_get_gui_width();
    var now_playing_x = gui_w - 30; // 30px from right edge
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
    draw_text_transformed(now_playing_x + 1, now_playing_y + line_spacing + 1, song_names[current_song], text_scale * 0.9, text_scale * 0.9, 0);
    draw_set_color(c_white);
    draw_text_transformed(now_playing_x, now_playing_y + line_spacing, song_names[current_song], text_scale * 0.9, text_scale * 0.9, 0);

    // Artist credit
    draw_set_color(c_black);
    draw_text_transformed(now_playing_x + 1, now_playing_y + line_spacing * 2 + 1, "by " + song_artist, text_scale * 0.75, text_scale * 0.75, 0);
    draw_set_color(make_color_rgb(180, 180, 180)); // Light gray
    draw_text_transformed(now_playing_x, now_playing_y + line_spacing * 2, "by " + song_artist, text_scale * 0.75, text_scale * 0.75, 0);

    // Reset draw settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
