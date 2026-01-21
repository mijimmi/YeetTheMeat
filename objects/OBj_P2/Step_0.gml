// === GET CONTROLLER OR KEYBOARD INPUT ===
var stick_x = 0;
var stick_y = 0;
var using_keyboard = false;

if (gamepad_is_connected(gamepad_slot)) {
    stick_x = gamepad_axis_value(gamepad_slot, gp_axislh);
    stick_y = gamepad_axis_value(gamepad_slot, gp_axislv);
}
else {
    using_keyboard = true;
    if (keyboard_check(ord("A"))) stick_x -= 1;
    if (keyboard_check(ord("D"))) stick_x += 1;
    if (keyboard_check(ord("W"))) stick_y -= 1;
    if (keyboard_check(ord("S"))) stick_y += 1;
    
    if (stick_x != 0 && stick_y != 0) {
        stick_x *= 0.707;
        stick_y *= 0.707;
    }
}

var stick_magnitude = point_distance(0, 0, stick_x, stick_y);
var stick_active = stick_magnitude > stick_deadzone;

var cancel_pressed = false;
if (gamepad_is_connected(gamepad_slot)) {
    cancel_pressed = gamepad_button_check_pressed(gamepad_slot, gp_face2);
} else {
    cancel_pressed = keyboard_check_pressed(vk_shift) || keyboard_check_pressed(vk_escape);
}

// === STATE MACHINE ===
switch (state) {
    case "idle":
        if (!stick_active) {
            cancel_cooldown = false;
        }
        
        if (landing_timer > 0) {
            landing_timer--;
            target_scale_x = 1.4;
            target_scale_y = 0.6;
        } else {
            target_scale_x = 1;
            target_scale_y = 1;
        }
        
        if (gamepad_is_connected(gamepad_slot)) {
            gamepad_set_vibration(gamepad_slot, 0, 0);
        }
        
        if (stick_active && !cancel_cooldown && landing_timer <= 0) {
            state = "aiming";
            aim_power = 0;
            aim_power_raw = 0;
            power_direction = 1;
            stick_held = true;
        }
        break;
        
    case "aiming":
        if (cancel_pressed) {
            state = "idle";
            aim_power = 0;
            aim_power_raw = 0;
            power_direction = 1;
            stick_held = false;
            cancel_cooldown = true;
            if (gamepad_is_connected(gamepad_slot)) {
                gamepad_set_vibration(gamepad_slot, 0, 0);
            }
        }
        else if (stick_active) {
            var stick_dir = point_direction(0, 0, stick_x, stick_y);
            aim_dir = stick_dir + 180;
            
            aim_power_raw += charge_rate * power_direction;
            
            if (aim_power_raw >= 1) {
                aim_power_raw = 1;
                power_direction = -1;
            }
            else if (aim_power_raw <= 0.1) {
                aim_power_raw = 0.1;
                power_direction = 1;
            }
            
            aim_power = aim_power_raw;
            
            target_scale_x = 1 + (aim_power * 0.3);
            target_scale_y = 1 - (aim_power * 0.2);
            
            if (gamepad_is_connected(gamepad_slot)) {
                var rumble_strength = aim_power * 0.4;
                gamepad_set_vibration(gamepad_slot, rumble_strength, rumble_strength);
            }
        }
        else if (stick_held && !stick_active) {
            if (aim_power >= min_power_threshold) {
                var launch_speed = aim_power * aim_power_max;
                velocity_x = lengthdir_x(launch_speed, aim_dir);
                velocity_y = lengthdir_y(launch_speed, aim_dir);
                state = "moving";
                
                target_scale_x = 0.6;
                target_scale_y = 1.4;
                
                shake_amount = aim_power * 10;
                
                if (gamepad_is_connected(gamepad_slot)) {
                    gamepad_set_vibration(gamepad_slot, 1, 1);
                }
                alarm[0] = 8;
            } else {
                state = "idle";
                if (gamepad_is_connected(gamepad_slot)) {
                    gamepad_set_vibration(gamepad_slot, 0, 0);
                }
            }
            aim_power = 0;
            aim_power_raw = 0;
            power_direction = 1;
            stick_held = false;
        }
        
        // === PLAYER VS PLAYER COLLISION (WHILE AIMING) ===
        if (instance_exists(OBJ_P1) && place_meeting(x, y, OBJ_P1)) {
            var other_player = instance_nearest(x, y, OBJ_P1);
            
            var push_dir = point_direction(other_player.x, other_player.y, x, y);
            
            var impact_force = point_distance(0, 0, other_player.velocity_x, other_player.velocity_y);
            var bounce_strength = max(impact_force * 0.7, 2);
            
            // Cancel aiming and go to moving state
            state = "moving";
            
            velocity_x = lengthdir_x(bounce_strength, push_dir);
            velocity_y = lengthdir_y(bounce_strength, push_dir);
            
            // Make sure other player is in moving state
            if (other_player.state == "idle" || other_player.state == "aiming") {
                other_player.state = "moving";
                other_player.velocity_x = lengthdir_x(bounce_strength, push_dir + 180);
                other_player.velocity_y = lengthdir_y(bounce_strength, push_dir + 180);
                
                // If other was aiming, reset their aim variables
                if (other_player.state == "aiming") {
                    other_player.aim_power = 0;
                    other_player.aim_power_raw = 0;
                    other_player.power_direction = 1;
                    other_player.stick_held = false;
                }
            }
            
            // Reset aiming variables
            aim_power = 0;
            aim_power_raw = 0;
            power_direction = 1;
            stick_held = false;
            
            while (place_meeting(x, y, OBJ_P1)) {
                x += lengthdir_x(1, push_dir);
                y += lengthdir_y(1, push_dir);
            }
            
            shake_amount = impact_force * 0.3;
            if (gamepad_is_connected(gamepad_slot)) {
                gamepad_set_vibration(gamepad_slot, 0.8, 0.8);
            }
            alarm[0] = 6;
        }
        break;
        
    case "moving":
        var bounce_factor = 0.6;
        
        var new_x = x + velocity_x;
        if (place_meeting(new_x, y, OBJ_Collision)) {
            while (!place_meeting(x + sign(velocity_x), y, OBJ_Collision)) {
                x += sign(velocity_x);
            }
            velocity_x = -velocity_x * bounce_factor;
            shake_amount = abs(velocity_x) * 0.5;
        } else {
            x = new_x;
        }
        
        var new_y = y + velocity_y;
        if (place_meeting(x, new_y, OBJ_Collision)) {
            while (!place_meeting(x, y + sign(velocity_y), OBJ_Collision)) {
                y += sign(velocity_y);
            }
            velocity_y = -velocity_y * bounce_factor;
            shake_amount = abs(velocity_y) * 0.5;
        } else {
            y = new_y;
        }
        
        velocity_x *= friction_rate;
        velocity_y *= friction_rate;
        
        var current_speed = point_distance(0, 0, velocity_x, velocity_y);
        target_scale_x = 1 - min(current_speed * 0.02, 0.3);
        target_scale_y = 1 + min(current_speed * 0.03, 0.4);
        
        if (gamepad_is_connected(gamepad_slot)) {
            gamepad_set_vibration(gamepad_slot, 0, 0);
        }
        
        if (current_speed < 0.5) {
            target_scale_x = 1.4;
            target_scale_y = 0.6;
            landing_timer = 15;
            
            shake_amount = 4;
            
            if (gamepad_is_connected(gamepad_slot)) {
                gamepad_set_vibration(gamepad_slot, 0.6, 0.6);
            }
            alarm[0] = 6;
            
            velocity_x = 0;
            velocity_y = 0;
            state = "idle";
        }
		
		// === PLAYER VS PLAYER COLLISION (WHILE MOVING) ===
        if (instance_exists(OBJ_P1) && place_meeting(x, y, OBJ_P1)) {
            var other_player = instance_nearest(x, y, OBJ_P1);
            
            var push_dir = point_direction(other_player.x, other_player.y, x, y);
            
            var impact_force = point_distance(0, 0, velocity_x - other_player.velocity_x, velocity_y - other_player.velocity_y);
            var bounce_strength = max(impact_force * 0.7, 2);
            
            velocity_x = lengthdir_x(bounce_strength, push_dir);
            velocity_y = lengthdir_y(bounce_strength, push_dir);
            
            other_player.velocity_x = lengthdir_x(bounce_strength, push_dir + 180);
            other_player.velocity_y = lengthdir_y(bounce_strength, push_dir + 180);
            
            if (other_player.state == "idle") {
                other_player.state = "moving";
            }
            else if (other_player.state == "aiming") {
                other_player.state = "moving";
                // Reset their aiming variables
                other_player.aim_power = 0;
                other_player.aim_power_raw = 0;
                other_player.power_direction = 1;
                other_player.stick_held = false;
            }
            
            while (place_meeting(x, y, OBJ_P1)) {
                x += lengthdir_x(1, push_dir);
                y += lengthdir_y(1, push_dir);
            }
            
            shake_amount = impact_force * 0.3;
        }
        break;
}

// === SQUASH & STRETCH INTERPOLATION ===
scale_x = lerp(scale_x, target_scale_x, 0.25);
scale_y = lerp(scale_y, target_scale_y, 0.25);

// === SCREEN SHAKE DECAY ===
shake_amount *= shake_decay;
if (shake_amount < 0.1) shake_amount = 0;

// === SPRITE DIRECTION ===
var dir_to_use = 90;

if (state == "aiming") {
    dir_to_use = aim_dir + 180;
}
else if (state == "moving") {
    var spd = point_distance(0, 0, velocity_x, velocity_y);
    if (spd > 0.5) {
        dir_to_use = point_direction(0, 0, velocity_x, velocity_y) + 180;
    }
}

dir_to_use = (dir_to_use + 360) mod 360;

if (dir_to_use > 90 && dir_to_use < 270) {
    facing_flip = -1;
    dir_to_use = 180 - dir_to_use;
    if (dir_to_use < 0) dir_to_use += 360;
} else {
    facing_flip = 1;
}

dir_to_use = (dir_to_use + 360) mod 360;

if (dir_to_use >= 247.5 && dir_to_use < 292.5) {
    facing_frame = 0;
}
else if (dir_to_use >= 292.5 && dir_to_use < 337.5) {
    facing_frame = 1;
}
else if (dir_to_use >= 337.5 || dir_to_use < 22.5) {
    facing_frame = 2;
}
else if (dir_to_use >= 22.5 && dir_to_use < 67.5) {
    facing_frame = 3;
}
else if (dir_to_use >= 67.5 && dir_to_use < 112.5) {
    facing_frame = 4;
}

facing_frame = 4 - facing_frame;

// === HANDS ===
hand_bob_timer += hand_bob_speed;
var bob = sin(hand_bob_timer) * hand_bob_amount;

hand_scale_x = 1;
hand_scale_y = 1;

if (state == "aiming") {
    var stick_x_input = stick_x;  // Reuse from above
    var stick_y_input = stick_y;
    
    var stick_dir = point_direction(0, 0, stick_x_input, stick_y_input);
    var stick_mag = point_distance(0, 0, stick_x_input, stick_y_input);
    
    var reach_dist = hand_offset + (stick_mag * 15);
    
    hand1_x = lengthdir_x(reach_dist, stick_dir);
    hand1_y = lengthdir_y(reach_dist, stick_dir) + bob + 10;
    hand1_angle = stick_dir;
    
    hand2_x = lengthdir_x(reach_dist - 5, stick_dir + 15);
    hand2_y = lengthdir_y(reach_dist - 5, stick_dir + 15) + bob + 10;
    hand2_angle = stick_dir;
    
    hand_scale_x = 1 + (stick_mag * 0.3) + (aim_power * 0.2);
    hand_scale_y = 1 - (stick_mag * 0.1);
}
else {
    hand1_x = -hand_offset;
    hand1_y = bob + 10;
    hand1_angle = 180;
    
    hand2_x = hand_offset;
    hand2_y = bob + 12;
    hand2_angle = 0;
    
    hand_scale_x = 1;
    hand_scale_y = 1;
}