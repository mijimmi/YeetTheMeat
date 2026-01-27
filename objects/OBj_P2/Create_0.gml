// === MOVEMENT STATE ===
state = "idle";
velocity_x = 0;
velocity_y = 0;
friction_rate = 0.94;

// === AIMING / POWER SYSTEM ===
aim_dir = 0;
aim_power = 1;
aim_power_raw = 0;
aim_power_max = 35;
charge_rate = 0.025;
min_power_threshold = 0.1;
// Oscillating power
power_direction = 1;  // 1 = going up, -1 = going down

// === CONTROLLER ===
gamepad_slot = 1;
stick_held = false;
stick_deadzone = 0.3;
cancel_cooldown = false;

// === DIRECTION LOCK (prevents snap-back on stick release) ===
locked_stick_x = 0;
locked_stick_y = 0;

// === SQUASH & STRETCH ===
scale_x = 1;
scale_y = 1;
target_scale_x = 1;
target_scale_y = 1;
landing_timer = 0;

// === SCREEN SHAKE ===
shake_amount = 0;
shake_decay = 0.85;

// === SPRITE DIRECTION ===
facing_frame = 0;
facing_flip = 1;

// === VISUALS ===
arrow_length_max = 100;
arrow_color_weak = c_lime;
arrow_color_strong = c_red;

// === HANDS ===
hand_offset = 32;     // Distance from body
hand_bob_speed = 0.1;      // Floating bob speed
hand_bob_amount = 3;       // How much they bob up/down
hand_bob_timer = 0;

// Hand positions (relative to player)
hand1_x = 0;
hand1_y = 0;
hand2_x = 0;
hand2_y = 0;

// Hand angles (for rotation)
hand1_angle = 0;
hand2_angle = 0;
hand_scale_x = 1;
hand_scale_y = 1;
hand_frame = 0;

// === CANCEL HINT ===
aim_hold_timer = 0;
cancel_hint_delay = 2.5;  // Seconds before showing hint
cancel_hint_alpha = 0;

// === CLOUD TRAIL ===
cloud_list = ds_list_create();
cloud_spawn_timer = 0;
cloud_spawn_rate = 5;  // Spawn a cloud every X frames

// === INTERACTION / CARRYING ===
held_item = noone;           // What the player is holding
interact_range = 100;         // How close to interact with objects
interact_button = gp_face1;  // A button for pickup/drop/interact

// === COLLISION HITBOX ===
collision_width = 40;   // Vertical rectangle width
collision_height = 60;  // Vertical rectangle height (taller than wide)

// === AIM COOLDOWN ===
aim_cooldown = 0;
aim_cooldown_max = 20;  // Frames of cooldown (15 = 0.25 seconds at 60fps)

// === IDLE INDICATOR ===
idle_timer = 0;
idle_indicator_delay = 120;  // 2 seconds at 60fps

// === INPUT BUFFER ===
input_buffer_frames = 8;  // How many frames to remember inputs
take_buffer = 0;
place_buffer = 0;
drop_buffer = 0;

// === HELD ITEM BOB ===
held_item_bob_timer = 0;
held_item_bob_speed = 0.08;
held_item_bob_amount = 2;  // Very slight bob
