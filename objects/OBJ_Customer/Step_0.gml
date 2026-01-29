// Don't update customer when game is paused (e.g., recipe book open)
if (global.game_paused) {
    exit;
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
            thought_bubble_alpha = 0;
            
            if (instance_exists(OBJ_Scoring)) {
                OBJ_Scoring.add_score(OBJ_Scoring.points_penalty);
            }
            
            cleanup_table();
            
            // Reset path so a new one is created to the exit
            has_path = false;
        }
        break;
        
    case "eating":
        thought_bubble_alpha = max(thought_bubble_alpha - 0.1, 0);
        wait_timer++;
        
        if (wait_timer >= eat_time) {
            customer_state = "leaving";
            cleanup_table();
            
            // Reset path so a new one is created to the exit
            has_path = false;
        }
        break;
        
    case "leaving":
    // Set exit as target
	    if (spawner != noone) {
	        target_x = spawner.exit_x;
	        target_y = spawner.exit_y;
	    }
	    // If no spawner (tutorial mode), exit position should already be set
    
	    // Follow path to exit
	    follow_path();
    
	    // Fallback: if path complete or no path, move directly toward exit
	    if (!has_path || path_progress >= 0.99) {
	        var dir = point_direction(x, y, target_x, target_y);
	        var dist = point_distance(x, y, target_x, target_y);
	        if (dist > move_speed) {
	            x += lengthdir_x(move_speed, dir);
	            y += lengthdir_y(move_speed, dir);
	        }
	    }
    
	    // Destroy when reached exit
	    if (point_distance(x, y, target_x, target_y) < 20) {
	        path_delete(my_path);
	        instance_destroy();
	    }
	    break;
	}