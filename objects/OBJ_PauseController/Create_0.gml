// Create Event
paused = false;
pause_surf = -1; // Surface to store game screenshot

// Button properties
button_width = 300;
button_height = 80;
button_spacing = 20;

// Button positions (relative to center)
resume_y_offset = -60;
restart_y_offset = 60;

selected_button = 0; // 0 = resume, 1 = restart
button_hover = -1; // -1 = none, 0 = resume, 1 = restart