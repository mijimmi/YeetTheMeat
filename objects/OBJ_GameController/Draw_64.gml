// === DRAW CONTROLLER DISCONNECT WARNING ===
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
    
    // Determine which player(s) disconnected
    var disconnect_text = "";
    if (p1_disconnected && p2_disconnected) {
        disconnect_text = "P1 & P2 DISCONNECTED";
    } else if (p1_disconnected) {
        disconnect_text = "P1 DISCONNECTED";
    } else if (p2_disconnected) {
        disconnect_text = "P2 DISCONNECTED";
    }
    
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
    
    // Main text in red/orange based on which player
    var text_color = c_red;
    if (p2_disconnected && !p1_disconnected) {
        text_color = make_color_rgb(255, 140, 40); // Orange for P2
    } else if (p1_disconnected && p2_disconnected) {
        text_color = c_yellow;
    }
    
    draw_set_color(text_color);
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
