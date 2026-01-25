// NO PARENT - This is a standalone ingredient object

// === ITEM STATE ===
is_held = false;
held_by = noone;

// === VEGGIE STATE ===
veggie_state = "raw";  // ← ADD THIS! States: "raw", "sliced"

// Sprite
sprite_index = spr_lettuce;

// === PHYSICS ===
velocity_x = 0;
velocity_y = 0;
friction_rate = 0.94;
can_slide = true;

// === COLLISION MASK ===
collision_box_size = 20;

// === VISUALS ===
bob_timer = 0;
bob_speed = 0.08;
bob_amount = 2;