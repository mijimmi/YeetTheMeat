if (show_grid) {
    // Draw the pathfinding grid
    for (var gx = 0; gx < grid_width; gx++) {
        for (var gy = 0; gy < grid_height; gy++) {
            var cell_x = gx * grid_size;
            var cell_y = gy * grid_size;
            
            if (mp_grid_get_cell(path_grid, gx, gy) == -1) {
                // Walkable
                draw_set_alpha(0.2);
                draw_set_color(c_green);
            } else {
                // Blocked
                draw_set_alpha(0.3);
                draw_set_color(c_red);
            }
            draw_rectangle(cell_x, cell_y, cell_x + grid_size, cell_y + grid_size, false);
        }
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}