is_held = false;
held_by = noone;

// What food is on this plate
food_on_plate = noone;
has_food = false;

// === PHYSICS (LIKE PLAYER AND FOOD) ===
velocity_x = 0;
velocity_y = 0;
friction_rate = 0.94;
can_slide = true;

// === COLLISION MASK ===
collision_box_size = 24; // 24x24 pixel centered square (slightly bigger than food)

// Visuals
bob_timer = 0;
bob_speed = 0.08;
bob_amount = 2;