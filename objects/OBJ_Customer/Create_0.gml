// === CUSTOMER STATE ===
customer_state = "walking";

// === GROUP INFO ===
my_group = noone;
my_table = noone;
my_chair_index = 0;

// === ORDER INFO ===
ordered_food_type = "";
order_sprite = noone;
order_name = "";
has_been_served = false;

// === TIMING ===
wait_timer = 0;
max_wait_time = 60 * 60;
eat_time = 60 * 5;

// === PATHFINDING ===
my_path = path_add(); // Create a path for this customer
target_x = x;
target_y = y;
move_speed = 2;
path_position = 0;
has_path = false;

// === INTERACTION ===
interact_range = 50;

// === COLLISION ===
collision_width = 30;
collision_height = 40;

// === VISUALS ===
thought_bubble_alpha = 0;
sprite_index = spr_placeholder;

spawner = instance_find(OBJ_CustomerSpawner, 0);

// === COLLISION ===
collision_width = 30;   // Customer hitbox width
collision_height = 40;  // Customer hitbox height

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

function create_path_to_target() {
    // Get pathfinding grid
    if (!instance_exists(OBJ_PathfindingGrid)) return false;
    
    var grid = OBJ_PathfindingGrid.path_grid;
    
    // Clear old path
    path_clear_points(my_path);
    
    // Find path using A*
    var path_found = mp_grid_path(grid, my_path, x, y, target_x, target_y, false);
    
    if (path_found) {
        has_path = true;
        path_position = 0;
        path_start(my_path, move_speed, path_action_stop, false);
        return true;
    }
    
    has_path = false;
    return false;
}

function follow_path() {
    // Follow the path if we have one
    if (!has_path) {
        create_path_to_target();
    }
    
    // Collision with players while walking
    handle_player_collision();
    
    // Collision with food
    handle_food_collision();
}

function handle_player_collision() {
    with (OBJ_P1) {
        var cust_half_w = other.collision_width / 2;
        var cust_half_h = other.collision_height / 2;
        var cust_left = other.x - cust_half_w;
        var cust_right = other.x + cust_half_w;
        var cust_top = other.y - cust_half_h;
        var cust_bottom = other.y + cust_half_h;
        
        var player_half_w = collision_width / 2;
        var player_half_h = collision_height / 2;
        var player_left = x - player_half_w;
        var player_right = x + player_half_w;
        var player_top = y - player_half_h;
        var player_bottom = y + player_half_h;
        
        var colliding = !(cust_right < player_left || 
                         cust_left > player_right || 
                         cust_bottom < player_top || 
                         cust_top > player_bottom);
        
        if (colliding) {
            var push_dir = point_direction(x, y, other.x, other.y);
            var dist_centers = point_distance(x, y, other.x, other.y);
            var min_dist = (player_half_w + player_half_h + cust_half_w + cust_half_h) / 2;
            var overlap = max(0, min_dist - dist_centers);
            
            if (overlap > 0) {
                var push_x = lengthdir_x(overlap * 0.5, push_dir);
                var push_y = lengthdir_y(overlap * 0.5, push_dir);
                
                if (!place_meeting(other.x + push_x, other.y, OBJ_Collision)) {
                    other.x += push_x;
                }
                if (!place_meeting(other.x, other.y + push_y, OBJ_Collision)) {
                    other.y += push_y;
                }
            }
        }
    }
}

function handle_food_collision() {
    with (OBJ_Food) {
        if (!is_held && !is_cooking && !is_on_plate && can_slide) {
            var half_box = collision_box_size / 2;
            var food_left = x - half_box;
            var food_right = x + half_box;
            var food_top = y - half_box;
            var food_bottom = y + half_box;
            
            var cust_half_w = other.collision_width / 2;
            var cust_half_h = other.collision_height / 2;
            var cust_left = other.x - cust_half_w;
            var cust_right = other.x + cust_half_w;
            var cust_top = other.y - cust_half_h;
            var cust_bottom = other.y + cust_half_h;
            
            var colliding = !(food_right < cust_left || 
                             food_left > cust_right || 
                             food_bottom < cust_top || 
                             food_top > cust_bottom);
            
            if (colliding) {
                var push_dir = point_direction(other.x, other.y, x, y);
                velocity_x = lengthdir_x(1.5, push_dir);
                velocity_y = lengthdir_y(1.5, push_dir);
            }
        }
    }
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