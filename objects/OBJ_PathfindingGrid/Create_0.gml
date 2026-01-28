// Create a grid for pathfinding
grid_size = 16; // Size of each grid cell (adjust based on your room)
grid_width = ceil(room_width / grid_size);
grid_height = ceil(room_height / grid_size);

// Create MP grid for pathfinding
path_grid = mp_grid_create(0, 0, grid_width, grid_height, grid_size, grid_size);

// Add all collision objects to the grid
mp_grid_add_instances(path_grid, OBJ_Collision, true);

// IMPORTANT: Make chair positions walkable (remove them from collision)
// We'll handle this per-table since chairs are at specific offsets
with (OBJ_Table_Parent) {
    for (var i = 0; i < array_length(chair_positions); i++) {
        var chair_x = x + chair_positions[i][0];
        var chair_y = y + chair_positions[i][1];
        
        // Clear collision at chair positions
        var grid_x = floor(chair_x / other.grid_size);
        var grid_y = floor(chair_y / other.grid_size);
        
        // Clear a small area around the chair (3x3 cells)
        for (var cx = -1; cx <= 1; cx++) {
            for (var cy = -1; cy <= 1; cy++) {
                var check_x = grid_x + cx;
                var check_y = grid_y + cy;
                if (check_x >= 0 && check_x < other.grid_width && check_y >= 0 && check_y < other.grid_height) {
                    mp_grid_clear_cell(other.path_grid, check_x, check_y);
                }
            }
        }
    }
}

// Debug: Draw grid (optional)
show_grid = false;