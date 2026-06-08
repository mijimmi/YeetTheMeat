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
            // Fully unserved customer leaves angry — apply penalty
            customer_state = "leaving";
            is_angry = true;
            is_retracing = false;

            if (instance_exists(OBJ_Scoring)) {
                OBJ_Scoring.add_score(OBJ_Scoring.points_penalty);
            }

            cleanup_table();
            has_path = false;

        } else if (wait_timer >= max_wait_time && has_been_served && has_second_order && !has_been_served2) {
            // Dual-order customer already got their first dish but ran out of
            // patience waiting for the second — no points at all, clear placed dish
            customer_state = "leaving";
            is_angry = true;
            is_retracing = false;

            // Wipe the pending score so nothing is awarded
            pending_score = 0;

            // Clear the visual dish that was already placed on the table
            dish1_placed  = false;
            dish1_sprite  = -1;
            dish2_placed  = false;
            dish2_sprite  = -1;

            cleanup_table();
            has_path = false;
        }
        break;
        
    case "eating":
        thought_bubble_alpha = max(thought_bubble_alpha - 0.1, 0);
        wait_timer++;

        if (!dishes_emptied) {
            // Still eating: cloud puffs are drawn over the dishes in Draw.
            if (wait_timer >= eat_time) {
                // Finished eating: turn each dish into an empty plate/cup,
                // shown briefly before the customer gets up to leave.
                dishes_emptied = true;
                empty_timer = 0;
                if (dish1_placed) dish1_sprite = dish1_is_drink ? spr_cup : spr_plate;
                if (dish2_placed) dish2_sprite = dish2_is_drink ? spr_cup : spr_plate;
            }
        } else {
            empty_timer++;
            if (empty_timer >= empty_linger) {
                customer_state = "leaving";
                is_retracing = false;
                cleanup_table();
                has_path = false;
            }
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

// === TABLE DISH LAYOUT + PROP MANAGEMENT ===
// Compute where the served dish(es) sit on the table (facing-aware, side by side
// for dual orders) and feed it to a dedicated prop instance so it can render in
// front of the table while a north-seated customer stays behind it.
dishUI_show = ((customer_state == "waiting" || customer_state == "eating") && (dish1_placed || dish2_placed));

if (dishUI_show) {
    // Front = toward the table centre (from the seat offset, with a facing fallback)
    var _fx = 0, _fy = 1;
    var _north_seat_dish = false;
    var _south_seat_dish = false;
    if (my_table != noone && instance_exists(my_table)
        && my_chair_index >= 0 && my_chair_index < array_length(my_table.chair_positions)) {
        var _cp2 = my_table.chair_positions[my_chair_index];
        var _ox = _cp2[0], _oy = _cp2[1];
        if (abs(_ox) > abs(_oy)) { _fx = (_ox < 0) ? 1 : -1; _fy = 0; }
        else {
            _fy = (_oy < 0) ? 1 : -1; _fx = 0;
            _north_seat_dish = (_oy < 0);
            _south_seat_dish = (_oy > 0);
        }
    } else {
        switch (facing_direction) {
            case "left":  _fx = -1; _fy =  0; break;
            case "right": _fx =  1; _fy =  0; break;
            case "up":    _fx =  0; _fy = -1; _south_seat_dish = true; break;
            default:      _fx =  0; _fy =  1; _north_seat_dish = true; break;
        }
    }

    // Per-direction distance from the customer (side seats sit a touch farther out).
    var _fd = (_fx != 0) ? 70 : 50;

    var _bx = x + _fx * _fd;
    var _by = y + _fy * _fd - 6;
    // Left/right seats: nudge food down so it sits on the table, not floating high.
    if (_fx != 0) _by += 18;

    var _perp_x = -_fy;
    var _perp_y =  _fx;

    // Dual orders reserve two side-by-side slots so the first served dish keeps
    // its spot and doesn't jump when the second one arrives.
    dishUI_both = has_second_order;
    dishUI_scale = has_second_order ? 0.72 : 0.9;
    var _dgap = 28;

    if (has_second_order) {
        dishUI_d1x = _bx - _perp_x * _dgap; dishUI_d1y = _by - _perp_y * _dgap;
        dishUI_d2x = _bx + _perp_x * _dgap; dishUI_d2y = _by + _perp_y * _dgap;
    } else {
        dishUI_d1x = _bx; dishUI_d1y = _by;
        dishUI_d2x = _bx; dishUI_d2y = _by;
    }

    // Each slot shows as soon as it's served (so a dual customer displays the
    // first dish while waiting for the second).
    dishUI_s1 = dish1_placed ? dish1_sprite : noone;
    dishUI_s2 = dish2_placed ? dish2_sprite : noone;
    dishUI_eating = (customer_state == "eating" && !dishes_emptied);

    // Ensure the prop exists and sort it relative to the table & the customer:
    //  - north seat: in front of the table AND in front of the customer ("above them")
    //  - south seat: in front of the table but BEHIND the customer ("behind them")
    //  - side seat:  in front of the customer
    if (dish_prop == noone || !instance_exists(dish_prop)) {
        dish_prop = instance_create_depth(x, y, 149, OBJ_CustomerDish);
        dish_prop.owner = id;
    }
    dish_prop.depth = _south_seat_dish ? 180 : 149;   // both stay < 200 (in front of the table)
} else if (dish_prop != noone && instance_exists(dish_prop)) {
    instance_destroy(dish_prop);
    dish_prop = noone;
}

// === DYNAMIC DEPTH (sort against the spr_BGdepth table layer) ===
// Seated customers sort by their seat: a NORTH-side customer sits BEHIND the
// table (hidden by the spr_BGdepth top-half art), everyone else in front. While
// walking/leaving we fall back to a feet-vs-structure test so they sort
// naturally against tables, counters and stations as they move.
var _depth_front  = 150;   // < 200 -> drawn over spr_BGdepth (in front of tables)
var _depth_behind = 350;   // > 200 -> hidden by spr_BGdepth (behind the table)

var _seated = (customer_state == "sitting" || customer_state == "waiting" || customer_state == "eating");
if (_seated && my_table != noone && instance_exists(my_table)
    && my_chair_index >= 0 && my_chair_index < array_length(my_table.chair_positions)) {
    var _cp = my_table.chair_positions[my_chair_index];
    var _north_seat = (_cp[1] < 0 && abs(_cp[1]) >= abs(_cp[0]));
    depth = _north_seat ? _depth_behind : _depth_front;
} else {
    var _zone_half_w = 110;
    var _vert_range  = 140;
    var _edge_tol    = 6;
    var _cf = bbox_bottom;
    var _cx = x;
    var _behind = false;
    var _occ_obj = [OBJ_CookingStation_Parent, OBJ_FoodStorage_Parent, OBJ_Table_Parent, OBJ_ServingCounter, OBJ_TrashCan];
    for (var _i = 0; _i < array_length(_occ_obj); _i++) {
        if (!instance_exists(_occ_obj[_i])) continue;
        with (_occ_obj[_i]) {
            if (abs(_cx - x) > _zone_half_w) continue;
            if (abs(_cf - y) > _vert_range) continue;
            if (_cf < y - _edge_tol) _behind = true;
        }
    }
    depth = _behind ? _depth_behind : _depth_front;
}