if (instruction_alpha > 0.01) {
    // Measure text
    draw_set_font(global.game_font); // Use default font or set your font
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var text_scale = 2.5; // Much bigger text
    var text_w = string_width(instruction_text) * text_scale;
    var text_h = string_height(instruction_text) * text_scale;
    
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
    
    // Draw text with scale
    draw_set_alpha(instruction_alpha);
    draw_set_color(text_color);
    draw_text_transformed(instruction_x, new_instruction_y, instruction_text, text_scale, text_scale, 0);
    
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
    var skip_y = new_instruction_y + (string_height(instruction_text) * 2.5) / 2 + box_padding + 30; // Below the instruction box
    
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
    
    // Draw "TUTORIAL COMPLETE!" text
    draw_set_alpha(1);
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    
    var complete_text = "TUTORIAL COMPLETE!";
    draw_text_transformed(gui_w / 2, gui_h / 2 - 80, complete_text, 3.0, 3.0, 0); // Bigger text, moved up
    
    // Draw instruction to continue
    draw_set_color(c_white);
    draw_text_transformed(gui_w / 2, gui_h / 2 + 20, "Press -A- to start the game!", 2.0, 2.0, 0); // Bigger text
    
    // Draw recipe book reminder
    draw_set_valign(fa_top);
    var reminder_text = "Press SELECT in game to learn how to cook other foods";
    draw_text_transformed(gui_w / 2, gui_h / 2 + 80, reminder_text, 1.5, 1.5, 0);
    
    // Draw collision warning
    draw_set_color(make_color_rgb(255, 150, 150)); // Light red color
    var warning_text = "DON'T BUMP INTO YOUR FRIEND OR CUSTOMERS!";
    var warning_subtext = "It will result in you dropping your food";
    draw_text_transformed(gui_w / 2, gui_h / 2 + 140, warning_text, 1.8, 1.8, 0);
    draw_set_color(c_white);
    draw_text_transformed(gui_w / 2, gui_h / 2 + 180, warning_subtext, 1.3, 1.3, 0);
    
    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}