// === CUSTOMER STATE ===
customer_state = "walking";  // States: "walking", "sitting", "waiting", "eating", "leaving"

// === GROUP INFO ===
my_group = noone;
my_table = noone;
my_chair_index = 0;

// === ORDER INFO ===
ordered_food_type = "";    // e.g., "cooked", "adobo"
order_sprite = noone;      // Sprite to show in thought bubble
order_name = "";           // Display name
has_been_served = false;

// === TIMING ===
wait_timer = 0;
max_wait_time = 60 * 60;   // 30 seconds (adjustable)
eat_time = 60 * 5;         // 5 seconds eating

// === MOVEMENT (Grid-based: only X and Y, no diagonals) ===
target_x = x;
target_y = y;
move_speed = 2;
path_to_target = [];       // Array of [x, y] waypoints
current_waypoint = 0;


// === INTERACTION ===
interact_range = 50;

// === VISUALS ===
thought_bubble_alpha = 0;
sprite_index = spr_placeholder;

// Get spawner reference
spawner = instance_find(OBJ_CustomerSpawner, 0);

function choose_order() {
    if (instance_exists(OBJ_CustomerSpawner)) {
        var orders = OBJ_CustomerSpawner.available_orders;
        var random_order = orders[irandom(array_length(orders) - 1)];
        
        ordered_food_type = random_order[0];
        order_sprite = random_order[1];
        order_name = random_order[2];
    }
}

function move_towards_target_grid() {
    // Grid-based movement with SOFT collision avoidance
    // Prefers to avoid OBJ_Collision but can pass through if needed
    var dx = target_x - x;
    var dy = target_y - y;
    
    // Check distance - if close enough, snap to target
    if (abs(dx) <= move_speed && abs(dy) <= move_speed) {
        x = target_x;
        y = target_y;
        return;
    }
    
    // Look-ahead distance for detecting collisions earlier
    var look_ahead = 32;
    
    // Calculate possible moves
    var horizontal_dir = sign(dx);
    var vertical_dir = sign(dy);
    
    // Check if going horizontal would lead into a collision (look ahead further)
    var horizontal_blocked = false;
    if (horizontal_dir != 0) {
        for (var i = move_speed; i <= look_ahead; i += move_speed) {
            if (check_collision_at(x + horizontal_dir * i, y)) {
                horizontal_blocked = true;
                break;
            }
        }
    }
    
    // Check if going vertical would lead into a collision
    var vertical_blocked = false;
    if (vertical_dir != 0) {
        for (var i = move_speed; i <= look_ahead; i += move_speed) {
            if (check_collision_at(x, y + vertical_dir * i)) {
                vertical_blocked = true;
                break;
            }
        }
    }
    
    // SOFT AVOIDANCE: Prefer clear paths
    
    // If horizontal is clear and we need to go that way, go horizontal
    if (abs(dx) > move_speed && !horizontal_blocked) {
        x += horizontal_dir * move_speed;
        return;
    }
    
    // If vertical is clear and we need to go that way, go vertical
    if (abs(dy) > move_speed && !vertical_blocked) {
        y += vertical_dir * move_speed;
        return;
    }
    
    // Primary direction blocked - try the other direction as detour
    if (horizontal_blocked && abs(dy) > 0) {
        // Go vertical instead to get around
        y += vertical_dir * move_speed;
        return;
    }
    
    if (vertical_blocked && abs(dx) > 0) {
        // Go horizontal instead to get around
        x += horizontal_dir * move_speed;
        return;
    }
    
    // Both blocked or at edge - just move towards target (soft avoidance, can pass through)
    if (abs(dx) > move_speed) {
        x += horizontal_dir * move_speed;
    } else if (abs(dy) > move_speed) {
        y += vertical_dir * move_speed;
    }
}

function check_collision_at(check_x, check_y) {
    // Check if a point is inside any OBJ_Collision instance
    var col = collision_point(check_x, check_y, OBJ_Collision, false, true);
    return (col != noone);
}

function cleanup_table() {
    // Remove self from table's customer list
    if (my_table != noone && instance_exists(my_table)) {
        for (var i = 0; i < array_length(my_table.customers_at_table); i++) {
            if (my_table.customers_at_table[i] == id) {
                array_delete(my_table.customers_at_table, i, 1);
                break;
            }
        }
    }
}

function serve_food(food_item) {
    // Only allow serving if customer is waiting and hasn't been served yet
    if (customer_state != "waiting" || has_been_served) {
        return false;
    }
    
    // Check if food matches order
    
    // For drinks, check food_type
    if (food_item.object_index == OBJ_Drink) {
        if (food_item.food_type == ordered_food_type) {
            // Correct drink!
            has_been_served = true;
            customer_state = "eating";
            wait_timer = 0;
            
            // Award points
            if (instance_exists(OBJ_Scoring)) {
                var points = OBJ_Scoring.get_food_points(ordered_food_type);
                OBJ_Scoring.add_score(points);
            }
            
            // Destroy the drink
            instance_destroy(food_item);
            return true;
        }
    }
    // For plated food, check sprite
    else if (food_item.food_type == "plated" && ordered_food_type == "plated") {
        // Check if the sprite matches what they ordered
        if (food_item.sprite_index == order_sprite) {
            // Correct food!
            has_been_served = true;
            customer_state = "eating";
            wait_timer = 0;
            
            // Award points
            if (instance_exists(OBJ_Scoring)) {
                var points = OBJ_Scoring.get_food_points_by_sprite(order_sprite);
                OBJ_Scoring.add_score(points);
            }
            
            // Destroy the food
            instance_destroy(food_item);
            return true;
        }
    }
    
    return false; // Wrong food/drink
}