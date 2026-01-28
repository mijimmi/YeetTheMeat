// === CHECK FOR CONTROLLER DISCONNECT PAUSE ===
if (variable_global_exists("controller_disconnected") && global.controller_disconnected) {
    exit; // Stop all player logic while disconnected
}

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

// === AIM COOLDOWN TIMER ===
if (aim_cooldown > 0) {
    aim_cooldown--;
}

// === INTERACTION SYSTEM (with input buffering) ===
// Decrement buffers
if (take_buffer > 0) take_buffer--;
if (place_buffer > 0) place_buffer--;
if (drop_buffer > 0) drop_buffer--;

// Check for new presses and fill buffer
if (gamepad_button_check_pressed(gamepad_slot, global.btn_take)) {
    take_buffer = input_buffer_frames;
}
if (gamepad_button_check_pressed(gamepad_slot, global.btn_place)) {
    place_buffer = input_buffer_frames;
}
if (gamepad_button_check_pressed(gamepad_slot, global.btn_drop)) {
    drop_buffer = input_buffer_frames;
}

// Execute buffered inputs
if (take_buffer > 0) {
    if (OBJ_ControlsManager.player_interact_take(id)) {
        take_buffer = 0;  // Clear buffer on success
    }
}

if (place_buffer > 0) {
    if (OBJ_ControlsManager.player_interact_place(id)) {
        place_buffer = 0;  // Clear buffer on success
    }
}

if (drop_buffer > 0) {
    if (OBJ_ControlsManager.player_drop_item(id)) {
        drop_buffer = 0;  // Clear buffer on success
    }
}

// === UPDATE HELD ITEM POSITION (with slight bob) ===
held_item_bob_timer += held_item_bob_speed;
if (held_item != noone && instance_exists(held_item)) {
    var bob_offset = sin(held_item_bob_timer) * held_item_bob_amount;
    held_item.x = x;
    held_item.y = y - 40 + bob_offset;
    held_item.depth = depth - 1;
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
        
        gamepad_set_vibration(gamepad_slot, 0, 0);
        
        if (stick_active && !cancel_cooldown && landing_timer <= 0 && aim_cooldown <= 0) {
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
        // Apply friction while sliding
        velocity_x *= friction_rate;
        velocity_y *= friction_rate;
        
        // Update aim hold timer
        aim_hold_timer += 1 / room_speed;
        
        // Fade in cancel hint after delay
        if (aim_hold_timer >= cancel_hint_delay) {
            cancel_hint_alpha = min(cancel_hint_alpha + 0.05, 1);
        } else {
            cancel_hint_alpha = 0;
        }
        
        // Cancel aiming
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
            // Only update aim direction when stick is well above deadzone
            // This prevents snap-back issues when releasing the stick
            var direction_threshold = 0.5;  // Higher threshold for direction updates
            
            if (stick_magnitude > direction_threshold) {
                var stick_dir = point_direction(0, 0, stick_x, stick_y);
                aim_dir = stick_dir + 180;
                // Store the locked direction for when magnitude drops
                locked_stick_x = stick_x;
                locked_stick_y = stick_y;
            }
            // If magnitude is between deadzone and threshold, keep the last good direction
            // (aim_dir stays unchanged, using the locked direction)
            
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
                velocity_x += lengthdir_x(launch_speed, aim_dir);
                velocity_y += lengthdir_y(launch_speed, aim_dir);
                state = "moving";
                
                target_scale_x = 0.6;
                target_scale_y = 1.4;
                
                shake_amount = aim_power * 10;
                
                gamepad_set_vibration(gamepad_slot, 1, 1);
                alarm[0] = 8;
            } else {
                state = "moving";
                gamepad_set_vibration(gamepad_slot, 0, 0);
            }
            
            // Start cooldown on ANY release from aiming
            aim_cooldown = aim_cooldown_max;
            
            aim_power = 0;
            aim_power_raw = 0;
            power_direction = 1;
            stick_held = false;
            aim_hold_timer = 0;
            cancel_hint_alpha = 0;
        }
        
        // === SPAWN CLOUD PUFFS WHILE SLIDING ===
        var current_speed = point_distance(0, 0, velocity_x, velocity_y);
        cloud_spawn_timer++;
        if (cloud_spawn_timer >= cloud_spawn_rate && current_speed > 1) {
            cloud_spawn_timer = 0;
            
            var trail_dir = point_direction(0, 0, velocity_x, velocity_y) + 180;
            var offset_dist = random_range(5, 15);
            
            var cloud_data = array_create(8);
            cloud_data[0] = x + lengthdir_x(offset_dist, trail_dir) + random_range(-3, 3);
            cloud_data[1] = y + 50 + random_range(-2, 2);
            cloud_data[2] = 0.7 + random(0.3);
            cloud_data[3] = 0.7;
            cloud_data[4] = 0.008;
            cloud_data[5] = choose(spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4);
            cloud_data[6] = 0;
            cloud_data[7] = 0;
            
            ds_list_add(cloud_list, cloud_data);
        }
        
        // === COLLISION-AWARE MOVEMENT WHILE AIMING ===
        var bounce_factor = 0.6;
        
        // X collision
        var new_x = x + velocity_x;
        if (place_meeting(new_x, y, OBJ_Collision)) {
            while (!place_meeting(x + sign(velocity_x), y, OBJ_Collision)) {
                x += sign(velocity_x);
            }
            
            // Spawn collision VFX
            var impact_speed = abs(velocity_x);
            if (impact_speed > 2) {
                var num_particles = floor(impact_speed / 2) + 2;
                for (var p = 0; p < num_particles; p++) {
                    var puff = array_create(8);
                    puff[0] = x + sign(velocity_x) * 20 + random_range(-10, 10);
                    puff[1] = y + random_range(-30, 30);
                    puff[2] = 0.5 + random(0.5);
                    puff[3] = 0.9;
                    puff[4] = 0.02;
                    puff[5] = choose(spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4);
                    puff[6] = random(360);
                    puff[7] = random_range(-5, 5);
                    ds_list_add(cloud_list, puff);
                }
            }
            
            velocity_x = -velocity_x * bounce_factor;
            shake_amount = abs(velocity_x) * 0.5;
            
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
            
            // Spawn collision VFX
            var impact_speed = abs(velocity_y);
            if (impact_speed > 2) {
                var num_particles = floor(impact_speed / 2) + 2;
                for (var p = 0; p < num_particles; p++) {
                    var puff = array_create(8);
                    puff[0] = x + random_range(-30, 30);
                    puff[1] = y + sign(velocity_y) * 20 + random_range(-10, 10);
                    puff[2] = 0.5 + random(0.5);
                    puff[3] = 0.9;
                    puff[4] = 0.02;
                    puff[5] = choose(spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4);
                    puff[6] = random(360);
                    puff[7] = random_range(-5, 5);
                    ds_list_add(cloud_list, puff);
                }
            }
            
            velocity_y = -velocity_y * bounce_factor;
            shake_amount = abs(velocity_y) * 0.5;
            
            var hit_strength = min(abs(velocity_y) / 10, 1);
            gamepad_set_vibration(gamepad_slot, hit_strength, hit_strength);
            alarm[0] = 5;
        } else {
            y = new_y;
        }
        
        // === PLAYER VS PLAYER COLLISION (WHILE AIMING) ===
        if (instance_exists(OBJ_P2) && place_meeting(x, y, OBJ_P2)) {
            var other_player = instance_nearest(x, y, OBJ_P2);
            
            var push_dir = point_direction(other_player.x, other_player.y, x, y);
            var impact_force = point_distance(0, 0, other_player.velocity_x, other_player.velocity_y);
            var bounce_strength = max(impact_force * 0.7, 2);
            
            // Spawn collision VFX burst at impact point
            var impact_x = (x + other_player.x) / 2;
            var impact_y = (y + other_player.y) / 2;
            var num_particles = max(floor(impact_force / 2) + 3, 4);
            for (var p = 0; p < num_particles; p++) {
                var puff = array_create(8);
                puff[0] = impact_x + random_range(-20, 20);
                puff[1] = impact_y + random_range(-20, 20);
                puff[2] = 0.6 + random(0.6);
                puff[3] = 1.0;
                puff[4] = 0.025;
                puff[5] = choose(spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4);
                puff[6] = random(360);
                puff[7] = random_range(-8, 8);
                ds_list_add(cloud_list, puff);
            }
            
            // === DROP HELD ITEMS ON PLAYER COLLISION ===
            // Drop P1's held item
            if (held_item != noone && instance_exists(held_item)) {
                held_item.is_held = false;
                held_item.held_by = noone;
                held_item.velocity_x = lengthdir_x(bounce_strength * 0.5, push_dir + random_range(-30, 30));
                held_item.velocity_y = lengthdir_y(bounce_strength * 0.5, push_dir + random_range(-30, 30));
                held_item = noone;
            }
            // Drop P2's held item
            if (other_player.held_item != noone && instance_exists(other_player.held_item)) {
                other_player.held_item.is_held = false;
                other_player.held_item.held_by = noone;
                other_player.held_item.velocity_x = lengthdir_x(bounce_strength * 0.5, push_dir + 180 + random_range(-30, 30));
                other_player.held_item.velocity_y = lengthdir_y(bounce_strength * 0.5, push_dir + 180 + random_range(-30, 30));
                other_player.held_item = noone;
            }
            
            state = "moving";
            
            velocity_x = lengthdir_x(bounce_strength, push_dir);
            velocity_y = lengthdir_y(bounce_strength, push_dir);
            
            if (other_player.state == "idle" || other_player.state == "aiming") {
                other_player.state = "moving";
                other_player.velocity_x = lengthdir_x(bounce_strength, push_dir + 180);
                other_player.velocity_y = lengthdir_y(bounce_strength, push_dir + 180);
                
                if (other_player.state == "aiming") {
                    other_player.aim_power = 0;
                    other_player.aim_power_raw = 0;
                    other_player.power_direction = 1;
                    other_player.stick_held = false;
                }
            }
            
            aim_power = 0;
            aim_power_raw = 0;
            power_direction = 1;
            stick_held = false;
            aim_hold_timer = 0;
            cancel_hint_alpha = 0;
            
            while (place_meeting(x, y, OBJ_P2)) {
                x += lengthdir_x(1, push_dir);
                y += lengthdir_y(1, push_dir);
            }
            
            shake_amount = impact_force * 0.3;
            gamepad_set_vibration(gamepad_slot, 0.8, 0.8);
            alarm[0] = 6;
        }
        break;
        
    case "moving":
        // Check cooldown before allowing aim while moving
        if (stick_active && !cancel_cooldown && aim_cooldown <= 0) {
            state = "aiming";
            aim_power = 0;
            aim_power_raw = 0;
            power_direction = 1;
            stick_held = true;
            aim_hold_timer = 0;
            cancel_hint_alpha = 0;
            break;
        }
        
        var bounce_factor = 0.6;
        
        // X collision
        var new_x = x + velocity_x;
        if (place_meeting(new_x, y, OBJ_Collision)) {
            while (!place_meeting(x + sign(velocity_x), y, OBJ_Collision)) {
                x += sign(velocity_x);
            }
            
            // Spawn collision VFX
            var impact_speed = abs(velocity_x);
            if (impact_speed > 2) {
                var num_particles = floor(impact_speed / 2) + 2;
                for (var p = 0; p < num_particles; p++) {
                    var puff = array_create(8);
                    puff[0] = x + sign(velocity_x) * 20 + random_range(-10, 10);
                    puff[1] = y + random_range(-30, 30);
                    puff[2] = 0.5 + random(0.5);
                    puff[3] = 0.9;
                    puff[4] = 0.02;
                    puff[5] = choose(spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4);
                    puff[6] = random(360);
                    puff[7] = random_range(-5, 5);
                    ds_list_add(cloud_list, puff);
                }
            }
            
            velocity_x = -velocity_x * bounce_factor;
            shake_amount = abs(velocity_x) * 0.5;
            
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
            
            // Spawn collision VFX
            var impact_speed = abs(velocity_y);
            if (impact_speed > 2) {
                var num_particles = floor(impact_speed / 2) + 2;
                for (var p = 0; p < num_particles; p++) {
                    var puff = array_create(8);
                    puff[0] = x + random_range(-30, 30);
                    puff[1] = y + sign(velocity_y) * 20 + random_range(-10, 10);
                    puff[2] = 0.5 + random(0.5);
                    puff[3] = 0.9;
                    puff[4] = 0.02;
                    puff[5] = choose(spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4);
                    puff[6] = random(360);
                    puff[7] = random_range(-5, 5);
                    ds_list_add(cloud_list, puff);
                }
            }
            
            velocity_y = -velocity_y * bounce_factor;
            shake_amount = abs(velocity_y) * 0.5;
            
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
            
            var trail_dir = point_direction(0, 0, velocity_x, velocity_y) + 180;
            var offset_dist = random_range(5, 15);
            
            var cloud_data = array_create(8);
            cloud_data[0] = x + lengthdir_x(offset_dist, trail_dir) + random_range(-3, 3);
            cloud_data[1] = y + 50 + random_range(-2, 2);
            cloud_data[2] = 0.7 + random(0.3);
            cloud_data[3] = 0.7;
            cloud_data[4] = 0.008;
            cloud_data[5] = choose(spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4);
            cloud_data[6] = 0;
            cloud_data[7] = 0;
            
            ds_list_add(cloud_list, cloud_data);
        }
        
        // === PLAYER VS PLAYER COLLISION (WHILE MOVING) ===
        if (instance_exists(OBJ_P2) && place_meeting(x, y, OBJ_P2)) {
            var other_player = instance_nearest(x, y, OBJ_P2);
            
            var push_dir = point_direction(other_player.x, other_player.y, x, y);
            var impact_force = point_distance(0, 0, velocity_x - other_player.velocity_x, velocity_y - other_player.velocity_y);
            var bounce_strength = max(impact_force * 0.7, 2);
            
            // Spawn collision VFX burst at impact point
            var impact_x = (x + other_player.x) / 2;
            var impact_y = (y + other_player.y) / 2;
            var num_particles = max(floor(impact_force / 2) + 4, 5);
            for (var p = 0; p < num_particles; p++) {
                var puff = array_create(8);
                puff[0] = impact_x + random_range(-25, 25);
                puff[1] = impact_y + random_range(-25, 25);
                puff[2] = 0.7 + random(0.7);
                puff[3] = 1.0;
                puff[4] = 0.03;
                puff[5] = choose(spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4);
                puff[6] = random(360);
                puff[7] = random_range(-10, 10);
                ds_list_add(cloud_list, puff);
            }
            
            // === DROP HELD ITEMS ON PLAYER COLLISION ===
            // Drop P1's held item
            if (held_item != noone && instance_exists(held_item)) {
                held_item.is_held = false;
                held_item.held_by = noone;
                held_item.velocity_x = lengthdir_x(bounce_strength * 0.5, push_dir + random_range(-30, 30));
                held_item.velocity_y = lengthdir_y(bounce_strength * 0.5, push_dir + random_range(-30, 30));
                held_item = noone;
            }
            // Drop P2's held item
            if (other_player.held_item != noone && instance_exists(other_player.held_item)) {
                other_player.held_item.is_held = false;
                other_player.held_item.held_by = noone;
                other_player.held_item.velocity_x = lengthdir_x(bounce_strength * 0.5, push_dir + 180 + random_range(-30, 30));
                other_player.held_item.velocity_y = lengthdir_y(bounce_strength * 0.5, push_dir + 180 + random_range(-30, 30));
                other_player.held_item = noone;
            }
            
            velocity_x = lengthdir_x(bounce_strength, push_dir);
            velocity_y = lengthdir_y(bounce_strength, push_dir);
            
            other_player.velocity_x = lengthdir_x(bounce_strength, push_dir + 180);
            other_player.velocity_y = lengthdir_y(bounce_strength, push_dir + 180);
            
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
            
            while (place_meeting(x, y, OBJ_P2)) {
                x += lengthdir_x(1, push_dir);
                y += lengthdir_y(1, push_dir);
            }
            
            shake_amount = impact_force * 0.3;
            gamepad_set_vibration(gamepad_slot, 0.9, 0.9);
            alarm[0] = 8;
        }
        break;
}

// === UPDATE CLOUD PUFFS ===
for (var i = ds_list_size(cloud_list) - 1; i >= 0; i--) {
    var cloud = cloud_list[| i];
    
    cloud[2] += cloud[4];
    cloud[3] -= 0.04;
    cloud[6] += cloud[7];
    
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

if (dir_to_use >= 330 || dir_to_use < 30) {
    facing_frame = 2;
}
else if (dir_to_use >= 150 && dir_to_use < 210) {
    facing_frame = 6;
}
else if (dir_to_use >= 60 && dir_to_use < 120) {
    facing_frame = 0;
}
else if (dir_to_use >= 240 && dir_to_use < 300) {
    facing_frame = 4;
}
else if (dir_to_use >= 30 && dir_to_use < 60) {
    facing_frame = 1;
}
else if (dir_to_use >= 120 && dir_to_use < 150) {
    facing_frame = 7;
}
else if (dir_to_use >= 210 && dir_to_use < 240) {
    facing_frame = 5;
}
else if (dir_to_use >= 300 && dir_to_use < 330) {
    facing_frame = 3;
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

// === IDLE INDICATOR TIMER ===
var player_speed = point_distance(0, 0, velocity_x, velocity_y);
if (player_speed < 0.5 && state == "idle") {
    idle_timer++;
} else {
    idle_timer = 0;
}

// === SCREEN WRAP ===
if (x > room_width) {
    x = 0;
}
else if (x < 0) {
    x = room_width;
}

// === FINAL PLAYER COLLISION CHECK FOR ITEM DROP (runs after all movement) ===
if (instance_exists(OBJ_P2) && place_meeting(x, y, OBJ_P2)) {
    var other_player = instance_nearest(x, y, OBJ_P2);
    var my_speed = point_distance(0, 0, velocity_x, velocity_y);
    var other_speed = point_distance(0, 0, other_player.velocity_x, other_player.velocity_y);
    
    // Only trigger drop if one of us is actually moving
    if (my_speed > 1 || other_speed > 1) {
        var push_dir = point_direction(other_player.x, other_player.y, x, y);
        var impact_force = point_distance(0, 0, velocity_x - other_player.velocity_x, velocity_y - other_player.velocity_y);
        var bounce_strength = max(impact_force * 0.7, 2);
        
        // Drop P1's held item
        if (held_item != noone && instance_exists(held_item)) {
            held_item.is_held = false;
            held_item.held_by = noone;
            held_item.velocity_x = lengthdir_x(bounce_strength * 0.5, push_dir + random_range(-30, 30));
            held_item.velocity_y = lengthdir_y(bounce_strength * 0.5, push_dir + random_range(-30, 30));
            held_item = noone;
        }
        // Drop P2's held item
        if (other_player.held_item != noone && instance_exists(other_player.held_item)) {
            other_player.held_item.is_held = false;
            other_player.held_item.held_by = noone;
            other_player.held_item.velocity_x = lengthdir_x(bounce_strength * 0.5, push_dir + 180 + random_range(-30, 30));
            other_player.held_item.velocity_y = lengthdir_y(bounce_strength * 0.5, push_dir + 180 + random_range(-30, 30));
            other_player.held_item = noone;
        }
    }
}