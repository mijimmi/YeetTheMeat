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
    
    if (abs(dx) > 0.5 || abs(dy) > 0.5) {
        if (abs(dx) > abs(dy)) {
            if (dx > 0) {
                facing_direction = "right";
            } else {
                facing_direction = "left";
            }
        } else {
            if (dy > 0) {
                facing_direction = "down";
            } else {
                facing_direction = "up";
            }
        }
    }
    
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
                sprite_index = customer_angry;
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
        follow_path();
        
        // Record waypoints as we walk in
        path_record_timer++;
        if (path_record_timer >= path_record_interval) {
            path_record_timer = 0;
            array_push(path_memory, [x, y]);
        }
        
        if (point_distance(x, y, target_x, target_y) < 10) {
            x = target_x;
            y = target_y;
            has_path = false;
            customer_state = "sitting";
            
            // Record final chair position then reverse for exit retracing
            array_push(path_memory, [x, y]);
            var reversed = [];
            for (var i = array_length(path_memory) - 1; i >= 0; i--) {
                array_push(reversed, path_memory[i]);
            }
            path_memory = reversed;
            path_memory_index = 0;
            
            determine_sitting_sprite();
            
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
            is_angry = true;
			is_retracing = false; 
            
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
			is_retracing = false; 
            cleanup_table();
            has_path = false;
        }
        break;
        
    case "leaving":
        thought_bubble_alpha = max(thought_bubble_alpha - 0.02, 0);
        
        var leave_speed = is_angry ? move_speed * 1.5 : move_speed;
        
        if (!is_retracing && array_length(path_memory) > 0) {
            // === RETRACE RECORDED PATH ===
            if (path_memory_index < array_length(path_memory)) {
                var wp   = path_memory[path_memory_index];
                var wp_x = wp[0];
                var wp_y = wp[1];
                var wp_dist = point_distance(x, y, wp_x, wp_y);
                
                if (wp_dist > leave_speed) {
                    var wp_dir = point_direction(x, y, wp_x, wp_y);
                    x += lengthdir_x(leave_speed, wp_dir);
                    y += lengthdir_y(leave_speed, wp_dir);
                } else {
                    // Reached this waypoint, advance to next
                    x = wp_x;
                    y = wp_y;
                    path_memory_index++;
                }
            } else {
                // Finished retracing, now pathfind to exit normally
                is_retracing = true;
                has_path = false;
                
                if (my_group != noone && instance_exists(my_group)) {
                    target_x = my_group.exit_x;
                    target_y = my_group.exit_y;
                } else if (spawner != noone) {
                    target_x = spawner.exit_x;
                    target_y = spawner.exit_y;
                }
            }
        } else {
            // === PATHFIND TO EXIT after retracing ===
            if (my_group != noone && instance_exists(my_group)) {
                target_x = my_group.exit_x;
                target_y = my_group.exit_y;
            } else if (spawner != noone) {
                target_x = spawner.exit_x;
                target_y = spawner.exit_y;
            }
            
            if (!has_path) {
                create_path_to_target();
            }
            
            follow_path();
            
            // Fallback movement
            if (!has_path || path_progress >= 0.99) {
                var dir  = point_direction(x, y, target_x, target_y);
                var dist = point_distance(x, y, target_x, target_y);
                if (dist > leave_speed) {
                    x += lengthdir_x(leave_speed, dir);
                    y += lengthdir_y(leave_speed, dir);
                }
            }
        }
        
        // Destroy when reached exit
        if (point_distance(x, y, target_x, target_y) < 20 && is_retracing) {
            path_delete(my_path);
            instance_destroy();
        }
        break;
}