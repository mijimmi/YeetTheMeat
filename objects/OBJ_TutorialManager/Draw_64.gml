if (instruction_alpha > 0.01) {
    // Measure text (use display text instead of full text)
    draw_set_font(global.game_font); // Use default font or set your font
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var text_scale = 2.5; // Much bigger text
    var text_w = string_width(instruction_text_full) * text_scale; // Use full text for box sizing
    var text_h = string_height(instruction_text_full) * text_scale;
    
    // Position between middle and bottom of screen
    var gui_h = display_get_gui_height();
    var center_y = gui_h / 2; // Middle of screen
    var bottom_y = gui_h; // Bottom of screen
    var new_instruction_y = (center_y + bottom_y) / 2; // Halfway between middle and bottom
    
    // === DRAW "TUTORIAL" TEXT ABOVE THE BOX ===
    if (current_phase != "complete") {
        var tutorial_text = "TUTORIAL";
        var tutorial_scale = 2.0; // Smaller scale
        var tutorial_y = new_instruction_y - (text_h / 2) - box_padding - 40; // Above the box
        
        draw_set_valign(fa_bottom);
        
        // Draw black outline
        draw_set_color(c_black);
        for (var ox = -2; ox <= 2; ox++) {
            for (var oy = -2; oy <= 2; oy++) {
                if (ox != 0 || oy != 0) {
                    draw_text_transformed(instruction_x + ox, tutorial_y + oy, tutorial_text, tutorial_scale, tutorial_scale, 0);
                }
            }
        }
        
        // Draw yellow text
        draw_set_alpha(instruction_alpha);
        draw_set_color(c_yellow);
        draw_text_transformed(instruction_x, tutorial_y, tutorial_text, tutorial_scale, tutorial_scale, 0);
        
        // Reset valign for instruction text
        draw_set_valign(fa_middle);
    }
    
    // Draw background box
    var box_x1 = instruction_x - (text_w / 2) - box_padding;
    var box_y1 = new_instruction_y - (text_h / 2) - box_padding;
    var box_x2 = instruction_x + (text_w / 2) + box_padding;
    var box_y2 = new_instruction_y + (text_h / 2) + box_padding;
    
    draw_set_alpha(box_alpha * instruction_alpha);
    draw_set_color(box_color);
    draw_rectangle(box_x1, box_y1, box_x2, box_y2, false);
    
    // Draw border
    draw_set_color(highlight_color);
    draw_rectangle(box_x1, box_y1, box_x2, box_y2, true);
    
    // Draw text with scale (use display text for typing effect)
    draw_set_alpha(instruction_alpha);
    draw_set_color(text_color);
    draw_text_transformed(instruction_x, new_instruction_y, instruction_text_display, text_scale, text_scale, 0);
    
    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// === SKIP TUTORIAL INSTRUCTION (Below main instruction) ===
if (current_phase != "complete" && instruction_alpha > 0.01) {
    var gui_h = display_get_gui_height();
    var center_y = gui_h / 2;
    var bottom_y = gui_h;
    var new_instruction_y = (center_y + bottom_y) / 2;
    
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    
    var skip_text = "Press SELECT to skip tutorial";
    var skip_scale = 1.5; // Bigger skip text
    var skip_y = new_instruction_y + (string_height(instruction_text_full) * 2.5) / 2 + box_padding + 30; // Below the instruction box
    
    // Draw text outline (black)
    draw_set_color(c_black);
    for (var xx = -2; xx <= 2; xx++) {
        for (var yy = -2; yy <= 2; yy++) {
            if (xx != 0 || yy != 0) {
                draw_text_transformed(instruction_x + xx, skip_y + yy, skip_text, skip_scale, skip_scale, 0);
            }
        }
    }
    
    // Draw main text (white)
    draw_set_alpha(instruction_alpha);
    draw_set_color(c_white);
    draw_text_transformed(instruction_x, skip_y, skip_text, skip_scale, skip_scale, 0);
    
    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// TUTORIAL COMPLETE SCREEN
if (current_phase == "complete") {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    
    // Draw dark overlay
    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gui_w, gui_h, false);
    
    // Draw "TUTORIAL COMPLETE!" text (with typing)
    draw_set_alpha(1);
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    
    draw_text_transformed(gui_w / 2, gui_h / 2 - 80, complete_text_display, 3.0, 3.0, 0); // Bigger text, moved up
    
    // Draw instruction to continue (with typing)
    draw_set_color(c_white);
    draw_text_transformed(gui_w / 2, gui_h / 2 + 20, continue_text_display, 2.0, 2.0, 0); // Bigger text
    
    // Draw recipe book reminder (with typing)
    draw_set_valign(fa_top);
    draw_text_transformed(gui_w / 2, gui_h / 2 + 80, reminder_text_display, 1.5, 1.5, 0);
    
    // Draw collision warning (with typing)
    draw_set_color(make_color_rgb(255, 150, 150)); // Light red color
    draw_text_transformed(gui_w / 2, gui_h / 2 + 140, warning_text_display, 1.8, 1.8, 0);
    draw_set_color(c_white);
    draw_text_transformed(gui_w / 2, gui_h / 2 + 180, warning_subtext_display, 1.3, 1.3, 0);
    
    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// === NOW PLAYING (Top Right Corner - Shows always) ===
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