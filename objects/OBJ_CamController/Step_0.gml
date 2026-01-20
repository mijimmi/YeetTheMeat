// === TARGET POSITION ===
var target_x = OBJ_P1.x - (cam_width / 2);
var target_y = OBJ_P1.y - (cam_height / 2);

// Optional: Look ahead in movement direction
if (OBJ_P1.state == "moving") {
    var spd = point_distance(0, 0, OBJ_P1.velocity_x, OBJ_P1.velocity_y);
    if (spd > 1) {
        var move_dir = point_direction(0, 0, OBJ_P1.velocity_x, OBJ_P1.velocity_y);
        target_x += lengthdir_x(look_ahead, move_dir);
        target_y += lengthdir_y(look_ahead, move_dir);
    }
}

// === SMOOTH FOLLOW ===
cam_x = lerp(cam_x, target_x, follow_speed);
cam_y = lerp(cam_y, target_y, follow_speed);

// === SCREEN SHAKE ===
shake_amount *= shake_decay;
if (shake_amount < 0.1) shake_amount = 0;

var shake_x = 0;
var shake_y = 0;
if (shake_amount > 0) {
    shake_x = random_range(-shake_amount, shake_amount);
    shake_y = random_range(-shake_amount, shake_amount);
}

// === APPLY CAMERA POSITION ===
camera_set_view_pos(cam, cam_x + shake_x, cam_y + shake_y);