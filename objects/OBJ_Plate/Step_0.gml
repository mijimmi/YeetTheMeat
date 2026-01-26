var current_speed = point_distance(0, 0, velocity_x, velocity_y);

// Check if on serving counter
var on_counter = false;
with (OBJ_ServingCounter) {
    if (plate_on_counter == other.id) {
        on_counter = true;
    }
}

// Gentle bobbing when not held, not moving, and not on counter
if (!is_held && current_speed < 0.3 && !on_counter) {
    bob_timer += bob_speed;
}

// Check if food still exists
if (food_on_plate != noone && !instance_exists(food_on_plate)) {
    food_on_plate = noone;
    has_food = false;
}

// Update food position if it exists
if (food_on_plate != noone && instance_exists(food_on_plate)) {
    food_on_plate.x = x;
    food_on_plate.y = y - 15; // Food sits on top of plate
    food_on_plate.depth = depth - 1;
    
    // Food inherits plate's velocity
    food_on_plate.velocity_x = velocity_x;
    food_on_plate.velocity_y = velocity_y;
}

// === PHYSICS - ONLY WHEN NOT HELD ===
if (!is_held && can_slide) {
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
    
    // === COLLISION WITH PLAYERS (PLATE GETS KICKED) ===
    with (OBJ_P1) {
        // Use plate's collision box instead of full sprite
        var half_box = other.collision_box_size / 2;
        var plate_left = other.x - half_box;
        var plate_right = other.x + half_box;
        var plate_top = other.y - half_box;
        var plate_bottom = other.y + half_box;
        
        // Use player's collision box
        var player_half_w = collision_width / 2;
        var player_half_h = collision_height / 2;
        var player_left = x - player_half_w;
        var player_right = x + player_half_w;
        var player_top = y - player_half_h;
        var player_bottom = y + player_half_h;
        
        // Check rectangle overlap
        var colliding = !(plate_right < player_left || 
                         plate_left > player_right || 
                         plate_bottom < player_top || 
                         plate_top > player_bottom);
        
        if (colliding && other.id != held_item) {
            // Direction from player to plate
            var push_dir = point_direction(x, y, other.x, other.y);
            
            // Calculate kick strength based on player's speed
            var player_speed = point_distance(0, 0, velocity_x, velocity_y);
            var plate_speed = point_distance(0, 0, other.velocity_x, other.velocity_y);
            
            // Combined impact force (like player-to-player collision)
            var impact_force = point_distance(0, 0, velocity_x - other.velocity_x, velocity_y - other.velocity_y);
            var kick_strength = max(impact_force * 0.6, player_speed * 0.4, 1.5);
            
            // Push plate away
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