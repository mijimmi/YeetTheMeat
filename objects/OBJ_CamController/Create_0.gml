// === CAMERA SETUP ===
cam = view_camera[0];

if (cam == -1) {
    cam = camera_create();
    view_camera[0] = cam;
}

// === ZOOM ===
zoom = 1;  // Change this! Higher = more zoomed in
base_width = 640;
base_height = 360;

cam_width = base_width / zoom;
cam_height = base_height / zoom;
camera_set_view_size(cam, cam_width, cam_height);

// Initialize position
if (instance_exists(OBJ_P1)) {
    cam_x = OBJ_P1.x - (cam_width / 2);
    cam_y = OBJ_P1.y - (cam_height / 2);
} else {
    cam_x = 0;
    cam_y = 0;
}

follow_speed = 0.1;
look_ahead = 50;

shake_amount = 0;
shake_decay = 0.85;