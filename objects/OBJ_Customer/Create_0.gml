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
    // Grid-based movement: only horizontal OR vertical, no diagonals
    var dx = target_x - x;
    var dy = target_y - y;
    
    // Move horizontally first, then vertically
    if (abs(dx) > move_speed) {
        x += sign(dx) * move_speed;
    } else if (abs(dy) > move_speed) {
        y += sign(dy) * move_speed;
    } else {
        // Close enough, snap to target
        x = target_x;
        y = target_y;
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