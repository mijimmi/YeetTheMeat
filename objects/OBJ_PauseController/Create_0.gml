// Create Event
paused = false;
pause_surf = -1; // Surface to store game screenshot

// Button properties
button_width = 300;
button_height = 80;
button_spacing = 20;

// Button positions (relative to center)
resume_y_offset = 40;
restart_y_offset = 120;

selected_button = 0; // 0 = resume, 1 = restart, 2 = menu, 3 = exit
button_hover = -1; // -1 = none, 0 = resume, 1 = restart

// Navigation cooldown to prevent rapid switching
nav_cooldown = 0;
nav_cooldown_max = 10; // frames between navigation

// Pause animation (slide up/down)
pause_anim_y = 300;  // Current Y offset (starts off-screen below)
pause_anim_target = 0; // Target Y offset (0 = centered)
pause_anim_speed = 0.12; // How fast to lerp
pause_anim_alpha = 0; // Fade in alpha
unpausing = false; // Track if we're in unpause animation