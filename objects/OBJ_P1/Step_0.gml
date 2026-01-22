// === GET CONTROLLER INPUT ===
var stick_x = 0;
var stick_y = 0;

if (gamepad_is_connected(gamepad_slot)) {
    stick_x = gamepad_axis_value(gamepad_slot, gp_axislh);
    stick_y = gamepad_axis_value(gamepad_slot, gp_axislv);
}

var stick_magnitude = point_distance(0, 0, stick_x, stick_y);
var stick_active = stick_magnitude > stick_deadzone;

var cancel_pressed = gamepad_button_check_pressed(gamepad_slot, gp_face2);

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
        
        gamepad_set_vibration(gamepad_slot, 0, 0);
        
        if (stick_active && !cancel_cooldown && landing_timer <= 0) {
            state = "aiming";
            aim_power = 0;
            aim_power_raw = 0;
            power_direction = 1;
            stick_held = true;
            aim_hold_timer = 0;
            cancel_hint_alpha = 0;
        }
        break;
        
    case "aiming":
        // Update aim hold timer
        aim_hold_timer += 1 / room_speed;
        
        // Fade in cancel hint after delay
        if (aim_hold_timer >= cancel_hint_delay) {
            cancel_hint_alpha = min(cancel_hint_alpha + 0.05, 1);
        } else {
            cancel_hint_alpha = 0;
        }
        
        if (cancel_pressed) {
            state = "idle";
            aim_power = 0;
            aim_power_raw = 0;
            power_direction = 1;
            stick_held = false;
            cancel_cooldown = true;
            aim_hold_timer = 0;
            cancel_hint_alpha = 0;
            gamepad_set_vibration(gamepad_slot, 0, 0);
        }
        else if (stick_active) {
            var stick_dir = point_direction(0, 0, stick_x, stick_y);
            aim_dir = stick_dir + 180;
            
            // OSCILLATING POWER (ping-pong)
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
            
            var rumble_strength = aim_power * 0.4;
            gamepad_set_vibration(gamepad_slot, rumble_strength, rumble_strength);
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
                
                gamepad_set_vibration(gamepad_slot, 1, 1);
                alarm[0] = 8;
            } else {
                state = "idle";
                gamepad_set_vibration(gamepad_slot, 0, 0);
            }
            aim_power = 0;
            aim_power_raw = 0;
            power_direction = 1;
            stick_held = false;
            aim_hold_timer = 0;
            cancel_hint_alpha = 0;
        }
        
        // === PLAYER VS PLAYER COLLISION (WHILE AIMING) ===
        if (instance_exists(OBJ_P2) && place_meeting(x, y, OBJ_P2)) {
            var other_player = instance_nearest(x, y, OBJ_P2);
            
            // Direction from other player to this player
            var push_dir = point_direction(other_player.x, other_player.y, x, y);
            
            // Combine velocities for impact force
            var impact_force = point_distance(0, 0, other_player.velocity_x, other_player.velocity_y);
            var bounce_strength = max(impact_force * 0.7, 2);
            
            // Cancel aiming and go to moving state
            state = "moving";
            
            // Push this player
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
            aim_hold_timer = 0;
            cancel_hint_alpha = 0;
            
            // Separate them so they don't overlap
            while (place_meeting(x, y, OBJ_P2)) {
                x += lengthdir_x(1, push_dir);
                y += lengthdir_y(1, push_dir);
            }
            
            // Effects
            shake_amount = impact_force * 0.3;
            gamepad_set_vibration(gamepad_slot, 0.8, 0.8);
            alarm[0] = 6;
        }
        break;
        
    case "moving":
        var bounce_factor = 0.6;
        
        // X collision
        var new_x = x + velocity_x;
        if (place_meeting(new_x, y, OBJ_Collision)) {
            while (!place_meeting(x + sign(velocity_x), y, OBJ_Collision)) {
                x += sign(velocity_x);
            }
            velocity_x = -velocity_x * bounce_factor;
            shake_amount = abs(velocity_x) * 0.5;
            
            // Rumble on wall hit
            var hit_strength = min(abs(velocity_x) / 10, 1);
            gamepad_set_vibration(gamepad_slot, hit_strength, hit_strength);
            alarm[0] = 5;
        } else {
            x = new_x;
        }
        
        // Y collision
        var new_y = y + velocity_y;
        if (place_meeting(x, new_y, OBJ_Collision)) {
            while (!place_meeting(x, y + sign(velocity_y), OBJ_Collision)) {
                y += sign(velocity_y);
            }
            velocity_y = -velocity_y * bounce_factor;
            shake_amount = abs(velocity_y) * 0.5;
            
            // Rumble on wall hit
            var hit_strength = min(abs(velocity_y) / 10, 1);
            gamepad_set_vibration(gamepad_slot, hit_strength, hit_strength);
            alarm[0] = 5;
        } else {
            y = new_y;
        }
        
        velocity_x *= friction_rate;
        velocity_y *= friction_rate;
        
        var current_speed = point_distance(0, 0, velocity_x, velocity_y);
        target_scale_x = 1 - min(current_speed * 0.02, 0.3);
        target_scale_y = 1 + min(current_speed * 0.03, 0.4);
        
        if (current_speed < 0.5) {
            target_scale_x = 1.4;
            target_scale_y = 0.6;
            landing_timer = 15;
            
            shake_amount = 4;
            
            gamepad_set_vibration(gamepad_slot, 0.6, 0.6);
            alarm[0] = 6;
            
            velocity_x = 0;
            velocity_y = 0;
            state = "idle";
        }
        
        // === SPAWN CLOUD PUFFS ===
        cloud_spawn_timer++;
        if (cloud_spawn_timer >= cloud_spawn_rate && current_speed > 1) {
            cloud_spawn_timer = 0;
            
            // Create cloud data: [x, y, scale, alpha, growth_rate]
            var cloud_data = array_create(5);
            cloud_data[0] = x + random_range(-8, 8);
            cloud_data[1] = y + 55 + random_range(-3, 3);
            cloud_data[2] = 0.3 + random(0.2);
            cloud_data[3] = 0.7 + random(0.3);
            cloud_data[4] = 0.02 + random(0.02);
            
            ds_list_add(cloud_list, cloud_data);
        }
        
        // === PLAYER VS PLAYER COLLISION (WHILE MOVING) ===
        if (instance_exists(OBJ_P2) && place_meeting(x, y, OBJ_P2)) {
            var other_player = instance_nearest(x, y, OBJ_P2);
            
            // Direction from other player to this player
            var push_dir = point_direction(other_player.x, other_player.y, x, y);
            
            // Combine velocities for impact force
            var impact_force = point_distance(0, 0, velocity_x - other_player.velocity_x, velocity_y - other_player.velocity_y);
            var bounce_strength = max(impact_force * 0.7, 2);
            
            // Push apart
            velocity_x = lengthdir_x(bounce_strength, push_dir);
            velocity_y = lengthdir_y(bounce_strength, push_dir);
            
            other_player.velocity_x = lengthdir_x(bounce_strength, push_dir + 180);
            other_player.velocity_y = lengthdir_y(bounce_strength, push_dir + 180);
            
            // Make sure other player is in moving state
            if (other_player.state == "idle") {
                other_player.state = "moving";
            }
            else if (other_player.state == "aiming") {
                other_player.state = "moving";
                other_player.aim_power = 0;
                other_player.aim_power_raw = 0;
                other_player.power_direction = 1;
                other_player.stick_held = false;
            }
            
            // Separate them so they don't overlap
            while (place_meeting(x, y, OBJ_P2)) {
                x += lengthdir_x(1, push_dir);
                y += lengthdir_y(1, push_dir);
            }
            
            // Effects
            shake_amount = impact_force * 0.3;
            gamepad_set_vibration(gamepad_slot, 0.9, 0.9);
            alarm[0] = 8;
        }
        
        break;
}

// === UPDATE CLOUD PUFFS ===
for (var i = ds_list_size(cloud_list) - 1; i >= 0; i--) {
    var cloud = cloud_list[| i];
    
    cloud[2] += cloud[4];  // Grow
    cloud[3] -= 0.03;      // Fade out
    
    // Remove if fully faded
    if (cloud[3] <= 0) {
        ds_list_delete(cloud_list, i);
    }
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

facing_flip = 1;

// Determine facing frame based on direction (full 360°)
// Frames: 0=Back, 1=Back-right, 2=Right, 3=Front-right, 4=Front, 5=Front-left, 6=Left, 7=Back-left

// Check cardinal directions FIRST with wider ranges
if (dir_to_use >= 330 || dir_to_use < 30) {
    facing_frame = 2;  // Right (0°) - 60° range
}
else if (dir_to_use >= 150 && dir_to_use < 210) {
    facing_frame = 6;  // Left (180°) - 60° range
}
else if (dir_to_use >= 60 && dir_to_use < 120) {
    facing_frame = 0;  // Back (90°) - 60° range
}
else if (dir_to_use >= 240 && dir_to_use < 300) {
    facing_frame = 4;  // Front (270°) - 60° range
}
// Then diagonals with remaining ranges
else if (dir_to_use >= 30 && dir_to_use < 60) {
    facing_frame = 1;  // Back-right (45°)
}
else if (dir_to_use >= 120 && dir_to_use < 150) {
    facing_frame = 7;  // Back-left (135°)
}
else if (dir_to_use >= 210 && dir_to_use < 240) {
    facing_frame = 5;  // Front-left (225°)
}
else if (dir_to_use >= 300 && dir_to_use < 330) {
    facing_frame = 3;  // Front-right (315°)
}

// === HANDS ===
hand_bob_timer += hand_bob_speed;
var bob = sin(hand_bob_timer) * hand_bob_amount;

hand_scale_x = 0.9;
hand_scale_y = 0.9;
hand_frame = 0;

if (state == "aiming") {
    var stick_x_input = 0;
    var stick_y_input = 0;
    if (gamepad_is_connected(gamepad_slot)) {
        stick_x_input = gamepad_axis_value(gamepad_slot, gp_axislh);
        stick_y_input = gamepad_axis_value(gamepad_slot, gp_axislv);
    }
    
    var stick_dir = point_direction(0, 0, stick_x_input, stick_y_input);
    var stick_mag = point_distance(0, 0, stick_x_input, stick_y_input);
    
    var reach_dist = hand_offset + 20 + (stick_mag * 20);
    
    hand1_x = lengthdir_x(reach_dist, stick_dir);
    hand1_y = lengthdir_y(reach_dist, stick_dir) + bob + 25;
    hand1_angle = stick_dir;
    
    hand2_x = lengthdir_x(reach_dist - 5, stick_dir + 15);
    hand2_y = lengthdir_y(reach_dist - 5, stick_dir + 15) + bob + 25;
    hand2_angle = stick_dir;
    
    hand_scale_x = 0.9 + (stick_mag * 0.3) + (aim_power * 0.2);
    hand_scale_y = 0.9 - (stick_mag * 0.1);
    hand_frame = 1;
}
else {
    hand1_x = -hand_offset;
    hand1_y = bob + 33;
    hand1_angle = 0;
    
    hand2_x = hand_offset;
    hand2_y = bob + 35;
    hand2_angle = 0;
    
    hand_scale_x = 0.9;
    hand_scale_y = 0.9;
    hand_frame = 0;
}

// === SCREEN WRAP ===
if (x > room_width) {
    x = 0;
}
else if (x < 0) {
    x = room_width;
}