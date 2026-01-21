// Create Event
cam = view_camera[0];
view_enabled = true;
view_visible[0] = true;

// Base viewport size
base_width = 1920;
base_height = 1080;

// Zoom settings
min_zoom = 1.0;  // Maximum zoom out (view = 1920x1080, the room size)
max_zoom = 2.0;  // Maximum zoom in (can zoom closer than default)
zoom_speed = 0.05;  // How quickly camera zooms
current_zoom = 2.0;  // Start zoomed in

// Camera smoothing
cam_smooth = 0.1;  // Lower = smoother, higher = snappier
target_x = room_width / 2;
target_y = room_height / 2;

// Padding (minimum distance from edge before zooming out)
padding = 200;