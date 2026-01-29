// Draw Event - Draw arrow indicator above target station

if (current_phase == "recipe" && tutorial_target_station != noone && instance_exists(tutorial_target_station)) {
    var station = tutorial_target_station;
    
    // Arrow position (above station)
    var arrow_x = station.x;
    var arrow_y = station.y - 80; // Base height above station
    var bounce_offset = sin(arrow_bounce) * 8; // Bounce up and down
    arrow_y += bounce_offset;
    
    // Arrow size
    var arrow_size = 16;
    var arrow_thickness = 3;
    var outline_thickness = 3; // Bigger outline
    
    // Draw arrow pointing down (triangle + line)
    // Black outline first (drawn larger)
    draw_set_color(c_black);
    draw_set_alpha(0.9);
    draw_triangle(
        arrow_x - arrow_size - outline_thickness, arrow_y + arrow_size - outline_thickness,
        arrow_x + arrow_size + outline_thickness, arrow_y + arrow_size - outline_thickness,
        arrow_x, arrow_y + arrow_size * 2 + outline_thickness,
        false
    );
    
    // Yellow triangle on top
    draw_set_color(c_yellow);
    draw_set_alpha(0.95);
    draw_triangle(
        arrow_x - arrow_size, arrow_y + arrow_size,
        arrow_x + arrow_size, arrow_y + arrow_size,
        arrow_x, arrow_y + arrow_size * 2,
        false
    );
    
    // Arrow shaft outline (black, thicker)
    draw_set_color(c_black);
    draw_set_alpha(0.9);
    draw_line_width(arrow_x, arrow_y, arrow_x, arrow_y + arrow_size, arrow_thickness + outline_thickness * 2);
    
    // Arrow shaft (yellow, on top)
    draw_set_color(c_yellow);
    draw_set_alpha(0.95);
    draw_line_width(arrow_x, arrow_y, arrow_x, arrow_y + arrow_size, arrow_thickness);
    
    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
}
