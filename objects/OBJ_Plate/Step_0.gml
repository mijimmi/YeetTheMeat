// Gentle bobbing when not held
if (!is_held) {
    bob_timer += bob_speed;
}

// Check if food still exists
if (food_on_plate != noone && !instance_exists(food_on_plate)) {
    food_on_plate = noone;
    has_food = false;
}

// Update food position if it exists
if (food_on_plate != noone && instance_exists(food_on_plate)) {
    food_on_plate.x = x;
    food_on_plate.y = y - 15; // Food sits on top of plate
    food_on_plate.depth = depth - 1;
}