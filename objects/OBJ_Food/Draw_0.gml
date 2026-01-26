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

// Draw shadow when not held
if (!is_held) {
    var shadow_y = y + 25;
    var shadow_width = 20 * draw_scale;
    var shadow_height = 8 * draw_scale;
    
    // Outer soft shadow
    draw_set_alpha(0.15);
    draw_set_color(c_black);
    draw_ellipse(x - shadow_width, shadow_y - shadow_height, x + shadow_width, shadow_y + shadow_height, false);
    
    // Inner darker shadow
    draw_set_alpha(0.25);
    draw_ellipse(x - shadow_width * 0.7, shadow_y - shadow_height * 0.7, x + shadow_width * 0.7, shadow_y + shadow_height * 0.7, false);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Children will override sprite_index based on food_type
draw_sprite_ext(sprite_index, 0, x, y + bob_offset, draw_scale, draw_scale, 0, c_white, 1);