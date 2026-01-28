// === MENU CONTROLLER ===

// Menu state: "main" or "mode_select"
menu_state = "main";

// === MAIN MENU ===
// Button selection (0 = Start, 1 = Leaderboard, 2 = Exit)
selected_button = 0;
total_buttons = 3;

// === MODE SELECT MENU ===
// 0 = Singleplayer, 1 = Multiplayer, 2 = Go Back
selected_mode = 0;
total_mode_buttons = 3;
mode_button_scales = [1, 1, 1];

// Global game mode (will be checked by game_room)
global.game_mode = "singleplayer";

// Title animation (fluid multi-layered motion)
title_time = 0;

// Primary float (slow, smooth up/down)
title_float_speed = 0.015;
title_float_amount = 6;

// Secondary bob (faster, smaller - adds life)
title_bob_speed = 0.04;
title_bob_amount = 2;

// Gentle sway rotation
title_sway_speed = 0.012;
title_sway_amount = 2;

// Subtle breathing scale
title_breathe_speed = 0.018;
title_breathe_amount = 0.015;  // 1.5% scale variation

// Slight horizontal drift
title_drift_speed = 0.01;
title_drift_amount = 4;

// Button outline settings
outline_thickness = 6;
outline_color = c_orange;

// Button pop animation
button_scales = [1, 1, 1];        // Current scale for each button
button_target_scale = 1.15;       // Scale when highlighted (main menu - bigger)
button_normal_scale = 1.0;        // Scale when not highlighted
button_scale_speed = 0.15;        // How fast to animate

// Input cooldown to prevent rapid selection
input_cooldown = 0;
input_delay = 10; // frames

// Get gamepad if connected
gamepad = -1;
for (var i = 0; i < gamepad_get_device_count(); i++) {
    if (gamepad_is_connected(i)) {
        gamepad = i;
        break;
    }
}
