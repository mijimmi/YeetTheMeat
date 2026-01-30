// Don't update customer when game is paused
var scoreboard_active = (instance_exists(OBJ_Scoring) && OBJ_Scoring.show_results);
if (global.game_paused || scoreboard_active) {
    exit;
}

// Update collision cloud cooldown
if (cloud_effect_cooldown > 0) {
    cloud_effect_cooldown--;
}

// === HANDLE TEMPORARY ANGRY STATE (from collisions) ===
if (temp_angry) {
    angry_timer++;
    is_angry = true;
    
    if (angry_timer >= angry_duration) {
        temp_angry = false;
        is_angry = false;
        angry_timer = 0;
    }
}

// === DETERMINE FACING DIRECTION BASED ON MOVEMENT ===
if (customer_state == "walking" || customer_state == "leaving") {
    var dx = x - last_x;
    var dy = y - last_y;
    
    // Only update direction if actually moving
    if (abs(dx) > 0.5 || abs(dy) > 0.5) {
        // Determine primary direction (horizontal vs vertical)
        if (abs(dx) > abs(dy)) {
            // Moving more horizontally
            if (dx > 0) {
                facing_direction = "right";
            } else {
                facing_direction = "left";
            }
        } else {
            // Moving more vertically
            if (dy > 0) {
                facing_direction = "down";
            } else {
                facing_direction = "up";
            }
        }
    }
    
    // Update last position
    last_x = x;
    last_y = y;
}

// === UPDATE SPRITE BASED ON STATE ===
if (customer_state == "walking" || customer_state == "leaving") {
    walk_sprite_timer++;
    
    var is_moving = (path_speed > 0) || (point_distance(x, y, target_x, target_y) > 5);
    
    if (is_moving) {
        if (walk_sprite_timer >= walk_sprite_speed) {
            walk_sprite_timer = 0;
            
            if (is_angry || temp_angry) {
                sprite_index = customer_angry; // CHANGED
            } else {
                switch (facing_direction) {
                    case "left":
                        sprite_index = (sprite_index == customer_walk_side1) ? customer_walk_side2 : customer_walk_side1; 
                        break;
                    case "right":
                        sprite_index = (sprite_index == customer_walk_side1_right) ? customer_walk_side2_right : customer_walk_side1_right; 
                        break;
                    case "up":
                        sprite_index = (sprite_index == customer_walk_back1) ? customer_walk_back2 : customer_walk_back1; 
                        break;
                    case "down":
                        sprite_index = (sprite_index == customer_walk_front1) ? customer_walk_front2 : customer_walk_front1; 
                        break;
                }
            }
        }
    } else {
        // Not moving - use first frame
        if (is_angry) {
            sprite_index = customer_angry; 
        } else {
            switch (facing_direction) {
                case "left":
                    sprite_index = customer_walk_side1; 
                    break;
                case "right":
                    sprite_index = customer_walk_side1_right; 
                    break;
                case "up":
                    sprite_index = customer_walk_back1; 
                    break;
                case "down":
                    sprite_index = customer_walk_front1; 
                    break;
            }
        }
        walk_sprite_timer = 0;
    }
} else {
    sprite_index = sitting_sprite;
    walk_sprite_timer = 0;
}

switch (customer_state) {
    case "walking":
        // Follow pathfinding
        follow_path();
        
        // Check if reached chair position
        if (point_distance(x, y, target_x, target_y) < 10) {
            x = target_x;
            y = target_y;
            has_path = false;
            customer_state = "sitting";
            
            // Determine sitting sprite based on chair position
            determine_sitting_sprite();
            
            // Start timer when first customer sits
            if (spawner != noone && instance_exists(spawner) && !spawner.first_customer_seated) {
                spawner.first_customer_seated = true;
                if (instance_exists(OBJ_TimerController)) {
                    OBJ_TimerController.start_timer();
                }
            }
        }
        break;
        
    case "sitting":
        customer_state = "waiting";
        wait_timer = 0;
        break;
        
    case "waiting":
        wait_timer++;
        thought_bubble_alpha = min(thought_bubble_alpha + 0.05, 1);
        
        if (wait_timer >= max_wait_time && !has_been_served) {
            customer_state = "leaving";
            is_angry = true; // Customer is angry!
            
            if (instance_exists(OBJ_Scoring)) {
                OBJ_Scoring.add_score(OBJ_Scoring.points_penalty);
            }
            
            cleanup_table();
            has_path = false;
        }
        break;
        
    case "eating":
        thought_bubble_alpha = max(thought_bubble_alpha - 0.1, 0);
        wait_timer++;
        
        if (wait_timer >= eat_time) {
            customer_state = "leaving";
            cleanup_table();
            has_path = false;
        }
        break;
        
    case "leaving":
        thought_bubble_alpha = max(thought_bubble_alpha - 0.02, 0);
        
        // Set exit as target
        if (spawner != noone) {
            target_x = spawner.exit_x;
            target_y = spawner.exit_y;
        }
        
        // Follow path to exit (faster if angry)
        var leave_speed = is_angry ? move_speed * 1.5 : move_speed;
        
        if (!has_path) {
            create_path_to_target();
            if (has_path) {
                path_speed = leave_speed;
            }
        }
        
        follow_path();
        
        // Fallback movement
        if (!has_path || path_progress >= 0.99) {
            var dir = point_direction(x, y, target_x, target_y);
            var dist = point_distance(x, y, target_x, target_y);
            if (dist > leave_speed) {
                x += lengthdir_x(leave_speed, dir);
                y += lengthdir_y(leave_speed, dir);
            }
        }
        
        // Destroy when reached exit
        if (point_distance(x, y, target_x, target_y) < 20) {
            path_delete(my_path);
            instance_destroy();
        }
        break;
}