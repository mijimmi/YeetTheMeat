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
    
    // Draw pause title
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(-1); // Use default font or set your own
    draw_set_color(c_white);
    draw_text_transformed(center_x, center_y - 150, "PAUSED", 2, 2, 0);
    
    // Draw Resume button
    var resume_selected = (selected_button == 0 || button_hover == 0);
    draw_set_color(resume_selected ? c_yellow : c_white);
    draw_rectangle(
        center_x - button_width / 2, 
        center_y + resume_y_offset - button_height / 2,
        center_x + button_width / 2, 
        center_y + resume_y_offset + button_height / 2,
        true
    );
    draw_set_color(resume_selected ? c_yellow : c_white);
    draw_text_transformed(center_x, center_y + resume_y_offset, "RESUME", 1.5, 1.5, 0);
    
    // Draw Restart button
    var restart_selected = (selected_button == 1 || button_hover == 1);
    draw_set_color(restart_selected ? c_yellow : c_white);
    draw_rectangle(
        center_x - button_width / 2, 
        center_y + restart_y_offset - button_height / 2,
        center_x + button_width / 2, 
        center_y + restart_y_offset + button_height / 2,
        true
    );
    draw_set_color(restart_selected ? c_yellow : c_white);
    draw_text_transformed(center_x, center_y + restart_y_offset, "RESTART", 1.5, 1.5, 0);
    
    // Draw controls hint
    draw_set_color(c_ltgray);
    draw_text(center_x, gui_height - 50, "ESC/START to resume  |  ENTER/A to select");
    
    // Reset draw settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}