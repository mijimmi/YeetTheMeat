// Create a grid for pathfinding
grid_size = 16; // Size of each grid cell (adjust based on your room)
grid_width = ceil(room_width / grid_size);
grid_height = ceil(room_height / grid_size);

// Create MP grid for pathfinding
path_grid = mp_grid_create(0, 0, grid_width, grid_height, grid_size, grid_size);

// The grid is populated with collision in rebuild_grid(). We do NOT populate it
// here because this Create event can run before the OBJ_CustomerCollision
// instances exist (per the room's instance creation order). It's (re)built at
// Room Start and lazily on first use, so timing can never leave it empty.
grid_ready = false;

function rebuild_grid() {
    // Start from a clean grid
    mp_grid_clear_all(path_grid);

    // Bake the customer-only collision walls into the grid by testing each cell
    // directly against OBJ_CustomerCollision. We do this manually (instead of
    // mp_grid_add_instances, which is unreliable with precise per-frame masks
    // like customer_coll) using collision_rectangle - the same precise collision
    // system the players collide with, so it always matches the painted mask.
    //
    // IMPORTANT: mp_grid_path routes the customer's CENTRE POINT, but the
    // customer SPRITE is large (~90px wide, bbox ~20..109 around a centred
    // origin => ~45px half-width). So we inflate the obstacles by that real
    // sprite half-width: a cell is only walkable if a customer-sprite-sized box
    // centred on it is fully clear of walls. Using the tiny 40px logical
    // collision box here is what let the visible body clip through tables.
    // Clearance baked around obstacles. The customer sprite is ~90px wide
    // (~45px half), but inflating by the full half-width seals narrow walkways
    // and spawn lanes. 34 keeps the body mostly clear while leaving corridors
    // open enough to path through.
    var cust_radius = 34;
    if (instance_exists(OBJ_CustomerCollision)) {
        for (var gx = 0; gx < grid_width; gx++) {
            for (var gy = 0; gy < grid_height; gy++) {
                var ccx = gx * grid_size + grid_size * 0.5;
                var ccy = gy * grid_size + grid_size * 0.5;
                if (collision_rectangle(ccx - cust_radius, ccy - cust_radius,
                                        ccx + cust_radius, ccy + cust_radius,
                                        OBJ_CustomerCollision, true, false) != noone) {
                    mp_grid_add_cell(path_grid, gx, gy);
                }
            }
        }
    }

    // Explicitly block every table's footprint, derived from its chair layout,
    // inflated by the customer radius. The hand-painted customer_coll mask
    // doesn't reliably cover every table (e.g. the middle one), so customers
    // could path straight through any table the mask missed. This guarantees
    // ALL tables block regardless of the painted mask.
    with (OBJ_Table_Parent) {
        var thw = 0, thh = 0, has_side = false, has_vert = false;
        for (var i = 0; i < array_length(chair_positions); i++) {
            var co = chair_positions[i];
            if (abs(co[0]) > abs(co[1])) { has_side = true; thw = max(thw, abs(co[0])); }
            else                         { has_vert = true; thh = max(thh, abs(co[1])); }
        }
        // Table body sits just inside the chairs; clamp so it stays sane.
        var body_hw = clamp(has_side ? thw - 35 : 75, 50, 95);
        var body_hh = clamp(has_vert ? thh - 35 : 55, 45, 70);

        mp_grid_add_rectangle(other.path_grid,
            x - body_hw - cust_radius, y - body_hh - cust_radius,
            x + body_hw + cust_radius, y + body_hh + cust_radius);
    }

    // Make chair positions walkable (carve them out of the collision)
    with (OBJ_Table_Parent) {
        for (var i = 0; i < array_length(chair_positions); i++) {
            var chair_x = x + chair_positions[i][0];
            var chair_y = y + chair_positions[i][1];

            var grid_x = floor(chair_x / other.grid_size);
            var grid_y = floor(chair_y / other.grid_size);

            // Clear an area around the chair (7x7 cells) so the seat stays
            // reachable through the inflated collision border around tables.
            for (var cx = -3; cx <= 3; cx++) {
                for (var cy = -3; cy <= 3; cy++) {
                    var check_x = grid_x + cx;
                    var check_y = grid_y + cy;
                    if (check_x >= 0 && check_x < other.grid_width && check_y >= 0 && check_y < other.grid_height) {
                        mp_grid_clear_cell(other.path_grid, check_x, check_y);
                    }
                }
            }
        }
    }

    grid_ready = true;
}

show_grid = false;
