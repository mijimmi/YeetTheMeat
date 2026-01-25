// === FOOD STATE ===
is_held = false;       // Is this being carried?
held_by = noone;       // Which player is holding it
food_type = "raw";     // "raw", "cooked", "burnt"

// === COOKING STATE ===
is_cooking = false;           // Currently on a cooking station
cooking_station = noone;      // Which station is cooking this
cook_timer = 0;               // How long it's been cooking

// === PLATING ===
is_on_plate = false;          // Is this food on a plate?
plate_instance = noone;       // Reference to the plate
plated_sprite = noone;        // Sprite to use when plated (set in child objects)

// === PHYSICS  ===
velocity_x = 0;
velocity_y = 0;
friction_rate = 0.94;         // Same as player
can_slide = true;             // Allow physics when dropped

// === VISUALS ===
bob_timer = 0;
bob_speed = 0.08;
bob_amount = 2;

// === COLLISION MASK ===
// Create a small centered square hitbox (consistent for all foods)
mask_index = -1; // We'll use a precise collision shape instead
collision_box_size = 100; // 20x20 pixel centered square (adjust as needed)