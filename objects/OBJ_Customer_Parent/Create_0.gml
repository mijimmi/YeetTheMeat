customer_walk_front1 = spr_customer1_front1;
customer_walk_front2 = spr_customer1_front2;
customer_walk_back1 = spr_customer1_back1;
customer_walk_back2 = spr_customer1_back2;
customer_walk_side1 = spr_customer1_side1;
customer_walk_side2 = spr_customer1_side2;
customer_walk_side1_right = spr_customer1_side1_right;
customer_walk_side2_right = spr_customer1_side2_right;

customer_sit_front = spr_customer1_front_sit;
customer_sit_back = spr_customer1_back_sit;
customer_sit_side = spr_customer1_side_sit;
customer_sit_side_right = spr_customer1_side_sit_right;

customer_angry = spr_customer1_angry;

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
max_wait_time = 60 * 90;   // 90 seconds (adjustable)
eat_time = 60 * 5;         // 5 seconds eating

// === PATHFINDING ===
my_path = path_add(); // Create a path for this customer
target_x = x;
target_y = y;
move_speed = 2;
path_progress = 0;  // Manual path progress tracking (0 to 1)
has_path = false;

// === COLLISION (add these lines) ===
collision_width = 40;   // Adjust to match your customer sprite width
collision_height = 40;  // Adjust to match your customer sprite height

// Collision cloud effect cooldown
cloud_effect_cooldown = 0;
cloud_effect_delay = 20; // Frames between cloud spawns (prevent spam)


// === INTERACTION ===
interact_range = 50;

// === VISUALS ===
thought_bubble_alpha = 0;

// === SPRITE ANIMATION ===
walk_sprite_timer = 0;
walk_sprite_speed = 8; // Frames between sprite changes
current_walk_sprite = spr_customer1_front1;

// Direction tracking
facing_direction = "down"; // "left", "right", "up", "down"
last_x = x;
last_y = y;

// Sitting sprite
sitting_sprite = spr_customer1_front_sit; 
sitting_xscale = 1; 

// Angry state
is_angry = false;
angry_timer = 0;         
angry_duration = 60;     
temp_angry = false;      

// === ORDER INFO ===
ordered_food_type = "";
order_sprite = noone;
order_name = "";
has_been_served = false;

// === SECOND ORDER (optional) ===
has_second_order = false;
ordered_food_type2 = "";
order_sprite2 = noone;
order_name2 = "";
has_been_served2 = false;

// Get spawner reference
spawner = instance_find(OBJ_CustomerSpawner, 0);

function choose_order() {
    if (!instance_exists(OBJ_CustomerSpawner)) return;

    var all_orders = OBJ_CustomerSpawner.available_orders;

    // === MAIN ORDER POOL: exclude rice, buko, gulaman ===
    var main_pool = [];
    for (var i = 0; i < array_length(all_orders); i++) {
        var ft = all_orders[i][0];
        var spr = all_orders[i][1];
        // Exclude gulaman, buko, and rice (plated rice dish)
        if (ft == "gulaman" || ft == "buko") continue;
        if (ft == "plated" && spr == spr_ricedish) continue;
        array_push(main_pool, all_orders[i]);
    }

    // === SIDE ORDER POOL: rice, buko, gulaman, kwek-kwek ===
    var side_pool = [];
    for (var i = 0; i < array_length(all_orders); i++) {
        var ft = all_orders[i][0];
        var spr = all_orders[i][1];
        if (ft == "gulaman" || ft == "buko") {
            array_push(side_pool, all_orders[i]);
            continue;
        }
        if (ft == "plated" && spr == spr_ricedish) {
            array_push(side_pool, all_orders[i]);
            continue;
        }
        if (ft == "plated" && spr == spr_takoyakidish) {
            array_push(side_pool, all_orders[i]);
            continue;
        }
    }

    // Pick main order
    var pick1 = main_pool[irandom(array_length(main_pool) - 1)];
    ordered_food_type = pick1[0];
    order_sprite      = pick1[1];
    order_name        = pick1[2];
    has_been_served   = false;

    // 15% chance of a second order
    if (random(1) < 0.5) {
        // Filter out any side that matches the main order
        var filtered_side = [];
        for (var i = 0; i < array_length(side_pool); i++) {
            var same_type   = (side_pool[i][0] == ordered_food_type);
            var same_sprite = (side_pool[i][1] == order_sprite);
            if (!(same_type && same_sprite)) {
                array_push(filtered_side, side_pool[i]);
            }
        }

        if (array_length(filtered_side) > 0) {
            var pick2 = filtered_side[irandom(array_length(filtered_side) - 1)];
            has_second_order    = true;
            ordered_food_type2  = pick2[0];
            order_sprite2       = pick2[1];
            order_name2         = pick2[2];
            has_been_served2    = false;
        }
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
        path_progress = 0;
        return true;
    }
    
    has_path = false;
    return false;
}

function follow_path() {
    // Create path if we don't have one
    if (!has_path) {
        create_path_to_target();
    }
    
    // Manually move along the path
    if (has_path && path_get_number(my_path) > 0) {
        var path_len = path_get_length(my_path);
        if (path_len > 0) {
            // Get target position on path
            var next_x = path_get_x(my_path, path_progress);
            var next_y = path_get_y(my_path, path_progress);
            
            // Move toward the next point
            var dir = point_direction(x, y, next_x, next_y);
            var dist = point_distance(x, y, next_x, next_y);
            
            if (dist > move_speed) {
                x += lengthdir_x(move_speed, dir);
                y += lengthdir_y(move_speed, dir);
            } else {
                // Reached this point, advance along path
                path_progress += move_speed / path_len;
                path_progress = min(path_progress, 1);
            }
        }
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
            // Make customer temporarily angry
            other.temp_angry = true;
            other.angry_timer = 0;
            
            var push_dir = point_direction(x, y, other.x, other.y);
            var dist_centers = point_distance(x, y, other.x, other.y);
            var min_dist = (player_half_w + player_half_h + cust_half_w + cust_half_h) / 2;
            var overlap = max(0, min_dist - dist_centers);
            
            if (overlap > 0) {
                // Drop held item
                if (held_item != noone && instance_exists(held_item)) {
                    held_item.x = x + lengthdir_x(20, push_dir + 180);
                    held_item.y = y + lengthdir_y(20, push_dir + 180) + 40;
                    held_item.is_held = false;
                    held_item.held_by = noone;
                    
                    if (object_is_ancestor(held_item.object_index, OBJ_Food)) {
                        held_item.velocity_x = velocity_x * 0.5;
                        held_item.velocity_y = velocity_y * 0.5;
                    }
                    else if (held_item.object_index == OBJ_Plate) {
                        held_item.velocity_x = velocity_x * 0.5;
                        held_item.velocity_y = velocity_y * 0.5;
                    }
                    else if (held_item.object_index == OBJ_Drink) {
                        held_item.velocity_x = velocity_x * 0.5;
                        held_item.velocity_y = velocity_y * 0.5;
                    }
                    
                    if (held_item.object_index == OBJ_Plate && held_item.has_food) {
                        var food = held_item.food_on_plate;
                        if (food != noone && instance_exists(food)) {
                            food.x = held_item.x;
                            food.y = held_item.y - 10;
                            food.velocity_x = velocity_x * 0.5;
                            food.velocity_y = velocity_y * 0.5;
                        }
                    }
                    
                    held_item = noone;
                }
                
                // Push customer
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
    
    with (OBJ_P2) {
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
            // MAKE CUSTOMER ANGRY WHEN HIT
            other.temp_angry = true;
            other.angry_timer = 0;
            
            var push_dir = point_direction(x, y, other.x, other.y);
            var dist_centers = point_distance(x, y, other.x, other.y);
            var min_dist = (player_half_w + player_half_h + cust_half_w + cust_half_h) / 2;
            var overlap = max(0, min_dist - dist_centers);
            
            if (overlap > 0) {
                // Drop held item
                if (held_item != noone && instance_exists(held_item)) {
                    held_item.x = x + lengthdir_x(20, push_dir + 180);
                    held_item.y = y + lengthdir_y(20, push_dir + 180) + 40;
                    held_item.is_held = false;
                    held_item.held_by = noone;
                    
                    if (object_is_ancestor(held_item.object_index, OBJ_Food)) {
                        held_item.velocity_x = velocity_x * 0.5;
                        held_item.velocity_y = velocity_y * 0.5;
                    }
                    else if (held_item.object_index == OBJ_Plate) {
                        held_item.velocity_x = velocity_x * 0.5;
                        held_item.velocity_y = velocity_y * 0.5;
                    }
                    else if (held_item.object_index == OBJ_Drink) {
                        held_item.velocity_x = velocity_x * 0.5;
                        held_item.velocity_y = velocity_y * 0.5;
                    }
                    
                    if (held_item.object_index == OBJ_Plate && held_item.has_food) {
                        var food = held_item.food_on_plate;
                        if (food != noone && instance_exists(food)) {
                            food.x = held_item.x;
                            food.y = held_item.y - 10;
                            food.velocity_x = velocity_x * 0.5;
                            food.velocity_y = velocity_y * 0.5;
                        }
                    }
                    
                    held_item = noone;
                }
                
                // Push customer
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
    if (customer_state != "waiting") return false;
    // Must have at least one unserved order
    if (has_been_served && (!has_second_order || has_been_served2)) return false;

    var matched = false;
    var points  = 0;

    // --- Helper: does this food item match an order slot? ---
    // Returns 1 = matched slot 1, 2 = matched slot 2, 0 = no match
    var slot_match = 0;

    // Check slot 1
    if (!has_been_served) {
        if (food_item.object_index == OBJ_Drink && food_item.food_type == ordered_food_type) {
            slot_match = 1;
        } else if (food_item.food_type == "plated" && ordered_food_type == "plated"
                   && food_item.sprite_index == order_sprite) {
            slot_match = 1;
        }
    }

    // Check slot 2 (only if slot 1 didn't match and second order exists)
    if (slot_match == 0 && has_second_order && !has_been_served2) {
        if (food_item.object_index == OBJ_Drink && food_item.food_type == ordered_food_type2) {
            slot_match = 2;
        } else if (food_item.food_type == "plated" && ordered_food_type2 == "plated"
                   && food_item.sprite_index == order_sprite2) {
            slot_match = 2;
        }
    }

    if (slot_match == 0) return false; // Wrong food

    // --- Award points ---
    if (instance_exists(OBJ_Scoring)) {
        if (slot_match == 1) {
            if (food_item.object_index == OBJ_Drink) {
                points = OBJ_Scoring.get_food_points(ordered_food_type);
            } else {
                points = OBJ_Scoring.get_food_points_by_sprite(order_sprite);
            }
        } else {
            if (food_item.object_index == OBJ_Drink) {
                points = OBJ_Scoring.get_food_points(ordered_food_type2);
            } else {
                points = OBJ_Scoring.get_food_points_by_sprite(order_sprite2);
            }
        }
        OBJ_Scoring.add_score(points);
        var popup = instance_create_depth(x, y - 50, depth - 200, OBJ_ScorePopup);
        popup.score_value = points;
    }

    // --- Mark slot as served ---
    if (slot_match == 1) has_been_served  = true;
    if (slot_match == 2) has_been_served2 = true;

    spawn_confetti();
    instance_destroy(food_item);

    // --- Move to eating only when ALL orders fulfilled ---
    var all_done = has_been_served && (!has_second_order || has_been_served2);
    if (all_done) {
        customer_state = "eating";
        wait_timer = 0;
    }

    return true;
}

function spawn_confetti() {
    // Spawn confetti particles above customer
    var confetti_count = 15;
    for (var i = 0; i < confetti_count; i++) {
        var confetti = instance_create_depth(
            x + random_range(-20, 20),
            y - 40,
            depth - 100,
            OBJ_Confetti
        );
    }
}

function determine_sitting_sprite() {
    if (my_table == noone || !instance_exists(my_table)) return;
    
    var chair_pos = my_table.chair_positions[my_chair_index];
    var chair_x_offset = chair_pos[0];
    var chair_y_offset = chair_pos[1];
    
    if (abs(chair_x_offset) > abs(chair_y_offset)) {
        // Side chairs
        if (chair_x_offset < 0) {
            sitting_sprite = customer_sit_side_right; 
        } else {
            sitting_sprite = customer_sit_side; 
        }
    } else {
        // Vertical chairs
        if (chair_y_offset < 0) {
            sitting_sprite = customer_sit_front; 
        } else {
            sitting_sprite = customer_sit_back; 
        }
    }
}