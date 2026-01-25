// Calculate current speed (needed for bobbing check)
var current_speed = point_distance(0, 0, velocity_x, velocity_y);

// Check if food is on a plate that's on serving counter
var on_counter = false;
if (is_on_plate && plate_instance != noone && instance_exists(plate_instance)) {
    with (OBJ_ServingCounter) {
        if (plate_on_counter == other.plate_instance) {
            on_counter = true;
        }
    }
}

var bob_offset = 0;
if (!is_held && !is_cooking && current_speed < 0.3 && !on_counter) {
    bob_offset = sin(bob_timer) * bob_amount;
}

// Scale when held (make smaller)
var draw_scale = 1;
if (is_held) {
    draw_scale = 0.7; // 70% size when held (adjust this value: 0.5 = 50%, 0.8 = 80%, etc.)
}

// Children will override sprite_index based on food_type
draw_sprite_ext(sprite_index, 0, x, y + bob_offset, draw_scale, draw_scale, 0, c_white, 1);