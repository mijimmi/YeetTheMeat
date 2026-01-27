var current_speed = point_distance(0, 0, velocity_x, velocity_y);

// Check if food is on a plate that's on serving counter
var on_counter = false;
if (is_on_plate && plate_instance != noone && instance_exists(plate_instance)) {
    with (OBJ_ServingCounter) {
        if (plate_on_counter == other.plate_instance) {
            on_counter = true;
        }
    }
}

if (!is_held && !is_cooking && current_speed < 0.3 && !on_counter) {
    bob_timer += bob_speed;
}

// === PLATING STATE TRANSITION ===
// When food is placed on a plate, change to "plated" state
if (is_on_plate && food_type != "plated") {
    // Check if this food has a plated sprite (meaning it's ready to be plated)
    if (plated_sprite != noone) {
        food_type = "plated";
    }
}

// === COOKING LOGIC ===
if (is_cooking && instance_exists(cooking_station)) {
    cook_timer++;
    
    // Check if station specifies custom output state (instant stations like slicing, soy sauce)
    if (variable_instance_exists(cooking_station, "output_state") && cooking_station.output_state != "") {
        // Custom state transition
        if (cook_timer >= cook_time_required) {
            food_type = cooking_station.output_state;
            cook_timer = 0;
        }
    } 
    // Only do default cooking if this is a simple food (Kwek, Rice, etc.)
    // Foods with custom cooking (Meat) will handle it in their own Step event
    else if (object_index == OBJ_KwekKwek || object_index == OBJ_Rice) {
        // Default cooking (raw → cooked → burnt)
        if (food_type == "raw" && cook_timer >= cook_time_required) {
            food_type = "cooked";
            cook_timer = 0;
        }
        else if (food_type == "cooked" && cook_timer >= burn_time) {
            food_type = "burnt";
        }
    }
    // For other foods (OBJ_Meat), let them handle their own cooking logic
    
    // === SPAWN COOKING SMOKE ===
    smoke_spawn_timer++;
    
    // Calculate smoke intensity based on cooking progress
    var smoke_progress = 0;
    var is_burning = (food_type == "burnt");
    
    // Determine if we're in "cooking" phase or "about to burn" phase
    var is_pre_burn_state = (food_type == "cooked" || food_type == "fried_pork" || food_type == "adobo" || 
                             food_type == "cooked_meat_lumpia" || food_type == "cooked_veggie_lumpia");
    
    if (variable_instance_exists(id, "cook_time_required") && cook_time_required > 0) {
        if (is_pre_burn_state && variable_instance_exists(id, "burn_time") && burn_time > 0) {
            // About to burn - darker smoke
            smoke_progress = 0.5 + (clamp(cook_timer / burn_time, 0, 1) * 0.5);
        } else if (!is_burning) {
            // Still cooking - lighter smoke
            smoke_progress = clamp(cook_timer / cook_time_required, 0, 1) * 0.5;
        }
    }
    if (is_burning) smoke_progress = 1;
    
    // Spawn rate increases as cooking progresses
    var current_spawn_rate = smoke_spawn_rate - floor(smoke_progress * 10);
    if (is_burning) current_spawn_rate = 5; // Fast smoke when burning
    
    if (smoke_spawn_timer >= current_spawn_rate) {
        smoke_spawn_timer = 0;
        
        // Pick random cloud sprite
        var smoke_sprites = [spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4];
        var smoke_spr = smoke_sprites[irandom(3)];
        
        // Calculate smoke color based on progress
        // Light gray (200,200,200) -> Medium gray (120,120,120) -> Dark/Black (40,40,40)
        var gray_value;
        if (smoke_progress < 0.5) {
            gray_value = lerp(220, 160, smoke_progress * 2);
        } else {
            gray_value = lerp(160, 30, (smoke_progress - 0.5) * 2);
        }
        var smoke_color = make_color_rgb(gray_value, gray_value, gray_value);
        
        // Create smoke particle [x, y, scale, alpha, life, sprite, rotation, vx, vy, color]
        var smoke_x = x + random_range(-15, 15);
        var smoke_y = y - 10 + random_range(-5, 5);
        var smoke_scale = random_range(0.3, 0.5) + (smoke_progress * 0.3);
        var smoke_vx = random_range(-0.3, 0.3);
        var smoke_vy = random_range(-0.8, -1.5) - (smoke_progress * 0.5);
        var smoke_rot = random(360);
        
        ds_list_add(smoke_list, [smoke_x, smoke_y, smoke_scale, 0.7, 60, smoke_spr, smoke_rot, smoke_vx, smoke_vy, smoke_color]);
    }
}

// === UPDATE SMOKE PARTICLES ===
for (var i = ds_list_size(smoke_list) - 1; i >= 0; i--) {
    var smoke = smoke_list[| i];
    
    // Update position
    smoke[0] += smoke[7]; // x += vx
    smoke[1] += smoke[8]; // y += vy
    smoke[8] *= 0.98;     // slow down vertical movement
    
    // Update scale (grow slightly)
    smoke[2] += 0.008;
    
    // Update alpha (fade out)
    smoke[3] -= 0.012;
    
    // Update rotation
    smoke[6] += random_range(-1, 1);
    
    // Update life
    smoke[4]--;
    
    // Remove dead particles
    if (smoke[4] <= 0 || smoke[3] <= 0) {
        ds_list_delete(smoke_list, i);
    } else {
        smoke_list[| i] = smoke;
    }
}

// === PHYSICS - ONLY WHEN NOT HELD, NOT COOKING, NOT ON PLATE ===
if (!is_held && !is_cooking && !is_on_plate && can_slide) {
    var bounce_factor = 0.6;
    
    // X collision with walls
    var new_x = x + velocity_x;
    if (place_meeting(new_x, y, OBJ_Collision)) {
        while (!place_meeting(x + sign(velocity_x), y, OBJ_Collision)) {
            x += sign(velocity_x);
        }
        velocity_x = -velocity_x * bounce_factor;
    } else {
        x = new_x;
    }
    
    // Y collision with walls
    var new_y = y + velocity_y;
    if (place_meeting(x, new_y, OBJ_Collision)) {
        while (!place_meeting(x, y + sign(velocity_y), OBJ_Collision)) {
            y += sign(velocity_y);
        }
        velocity_y = -velocity_y * bounce_factor;
    } else {
        y = new_y;
    }
    
    // Apply friction
    velocity_x *= friction_rate;
    velocity_y *= friction_rate;
    
    // Stop completely when speed is very low
    if (current_speed < 0.3) {
        velocity_x = 0;
        velocity_y = 0;
    }
    
    // === COLLISION WITH PLAYERS (FOOD GETS KICKED) ===
    with (OBJ_P1) {
        // Use food's collision box instead of full sprite
        var half_box = other.collision_box_size / 2;
        var food_left = other.x - half_box;
        var food_right = other.x + half_box;
        var food_top = other.y - half_box;
        var food_bottom = other.y + half_box;
        
        // Use player's collision box
        var player_half_w = collision_width / 2;
        var player_half_h = collision_height / 2;
        var player_left = x - player_half_w;
        var player_right = x + player_half_w;
        var player_top = y - player_half_h;
        var player_bottom = y + player_half_h;
        
        // Check rectangle overlap
        var colliding = !(food_right < player_left || 
                         food_left > player_right || 
                         food_bottom < player_top || 
                         food_top > player_bottom);
        
        if (colliding && other.id != held_item) {
            // Direction from player to food
            var push_dir = point_direction(x, y, other.x, other.y);
            
            // Calculate kick strength based on player's speed
            var player_speed = point_distance(0, 0, velocity_x, velocity_y);
            var food_speed = point_distance(0, 0, other.velocity_x, other.velocity_y);
            
            // Combined impact force (like player-to-player collision)
            var impact_force = point_distance(0, 0, velocity_x - other.velocity_x, velocity_y - other.velocity_y);
            var kick_strength = max(impact_force * 0.6, player_speed * 0.4, 1.5);
            
            // Push food away
            other.velocity_x = lengthdir_x(kick_strength, push_dir);
            other.velocity_y = lengthdir_y(kick_strength, push_dir);
            
            // Smooth separation (with wall collision check)
            var dist_centers = point_distance(x, y, other.x, other.y);
            var min_dist = (player_half_w + player_half_h) / 2 + half_box;
            var overlap = max(0, min_dist - dist_centers);
            
            if (overlap > 0) {
                var push_x = lengthdir_x(overlap * 0.5, push_dir);
                var push_y = lengthdir_y(overlap * 0.5, push_dir);
                
                // Check X push doesn't go into wall
                if (!place_meeting(other.x + push_x, other.y, OBJ_Collision)) {
                    other.x += push_x;
                } else {
                    other.velocity_x = 0;
                }
                
                // Check Y push doesn't go into wall
                if (!place_meeting(other.x, other.y + push_y, OBJ_Collision)) {
                    other.y += push_y;
                } else {
                    other.velocity_y = 0;
                }
            }
        }
    }
}