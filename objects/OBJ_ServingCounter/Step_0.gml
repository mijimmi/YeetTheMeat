if (plate_on_counter != noone && !instance_exists(plate_on_counter)) {
    plate_on_counter = noone;
}

// Update plate position (centered on counter)
if (plate_on_counter != noone && instance_exists(plate_on_counter)) {
    var plate = plate_on_counter;
    plate.x = x; // Center X
    plate.y = y + counter_offset_y; // Offset Y
    plate.depth = depth - 1;
    plate.can_slide = false; // No physics on counter
    plate.velocity_x = 0;
    plate.velocity_y = 0;
    
    // Update food position if plate has food
    if (plate.has_food && plate.food_on_plate != noone && instance_exists(plate.food_on_plate)) {
        var food = plate.food_on_plate;
        food.x = plate.x;
        food.y = plate.y - 15; // Food sits on top of plate
        food.depth = plate.depth - 1;
        food.can_slide = false;
        food.velocity_x = 0;
        food.velocity_y = 0;
    }
}