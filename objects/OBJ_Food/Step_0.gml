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