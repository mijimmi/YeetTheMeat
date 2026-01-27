// Create Event
cam = view_camera[0];
view_enabled = true;
view_visible[0] = true;

// Base viewport size
base_width = 1920;
base_height = 1080;

// Zoom settings
min_zoom = 1.0;
max_zoom = 1.15;
zoom_speed = 0.05;
current_zoom = 2.0;

// Camera smoothing
cam_smooth = 0.1;
target_x = room_width / 2;
target_y = room_height / 2;

// Padding
padding = 200;

// === CAMERA SHAKE ===
shake_x = 0;
shake_y = 0;
shake_intensity = 0;
shake_decay = 0.9;