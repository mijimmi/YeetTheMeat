if (instruction_alpha > 0.01) {
    // Measure text
    draw_set_font(global.game_font); // Use default font or set your font
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var text_w = string_width(instruction_text);
    var text_h = string_height(instruction_text);
    
    // Position between middle and bottom of screen
    var gui_h = display_get_gui_height();
    var center_y = gui_h / 2; // Middle of screen
    var bottom_y = gui_h; // Bottom of screen
    var new_instruction_y = (center_y + bottom_y) / 2; // Halfway between middle and bottom
    
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
    
    // Draw text
    draw_set_alpha(instruction_alpha);
    draw_set_color(text_color);
    draw_text(instruction_x, new_instruction_y, instruction_text);
    
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
    var skip_y = new_instruction_y + string_height(instruction_text) / 2 + box_padding + 30; // Below the instruction box
    
    // Draw text outline (black)
    draw_set_color(c_black);
    for (var xx = -2; xx <= 2; xx++) {
        for (var yy = -2; yy <= 2; yy++) {
            if (xx != 0 || yy != 0) {
                draw_text(instruction_x + xx, skip_y + yy, skip_text);
            }
        }
    }
    
    // Draw main text (white)
    draw_set_alpha(instruction_alpha);
    draw_set_color(c_white);
    draw_text(instruction_x, skip_y, skip_text);
    
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
    
    // Draw "TUTORIAL COMPLETE!" text
    draw_set_alpha(1);
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    
    var complete_text = "TUTORIAL COMPLETE!";
    draw_text_transformed(gui_w / 2, gui_h / 2 - 50, complete_text, 2, 2, 0); // Large text
    
    // Draw instruction to continue
    draw_set_color(c_white);
    draw_text(gui_w / 2, gui_h / 2 + 50, "Press -A- to start the game!");
    
    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}