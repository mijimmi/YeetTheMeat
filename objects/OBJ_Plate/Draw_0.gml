var current_speed = point_distance(0, 0, velocity_x, velocity_y);

// Check if on serving counter
var on_counter = false;
with (OBJ_ServingCounter) {
    if (plate_on_counter == other.id) {
        on_counter = true;
    }
}

var bob_offset = 0;
if (!is_held && current_speed < 0.3 && !on_counter) {
    bob_offset = sin(bob_timer) * bob_amount;
}

// Scale when held (make smaller)
var draw_scale = 1;
if (is_held) {
    draw_scale = 0.7; // 70% size when held (adjust this value)
}

// Draw shadow when not held
if (!is_held) {
    var shadow_y = y + 25;
    var shadow_width = 22 * draw_scale;
    var shadow_height = 9 * draw_scale;
    
    draw_set_alpha(0.15);
    draw_set_color(c_black);
    draw_ellipse(x - shadow_width, shadow_y - shadow_height, x + shadow_width, shadow_y + shadow_height, false);
    
    draw_set_alpha(0.25);
    draw_ellipse(x - shadow_width * 0.7, shadow_y - shadow_height * 0.7, x + shadow_width * 0.7, shadow_y + shadow_height * 0.7, false);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Only draw plate if there's no plated food on it
// (plated food sprite includes the plate visual)
var should_draw_plate = true;
if (has_food && food_on_plate != noone && instance_exists(food_on_plate)) {
    if (food_on_plate.food_type == "plated") {
        should_draw_plate = false; // Don't draw plate, food sprite shows it
    }
}

if (should_draw_plate) {
    draw_sprite_ext(sprite_index, 0, x, y + bob_offset, draw_scale, draw_scale, 0, c_white, 1);
}