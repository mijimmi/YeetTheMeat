switch (customer_state) {
    case "walking":
        // Follow pathfinding
        follow_path();
        
        // Check if reached chair position
        if (point_distance(x, y, target_x, target_y) < 10) {
            x = target_x;
            y = target_y;
            path_end(); // Stop following path
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
        }
        break;
        
    case "eating":
        thought_bubble_alpha = max(thought_bubble_alpha - 0.1, 0);
        wait_timer++;
        
        if (wait_timer >= eat_time) {
            customer_state = "leaving";
            cleanup_table();
        }
        break;
        
    case "leaving":
        // Create path to exit
        target_x = spawner.exit_x;
        target_y = spawner.exit_y;
        
        follow_path();
        
        // Destroy when reached exit
        if (point_distance(x, y, target_x, target_y) < 10) {
            path_delete(my_path);
            instance_destroy();
        }
        break;
}