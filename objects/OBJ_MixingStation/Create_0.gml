event_inherited();
food_offset_x = 15;
food_offset_y = -20;

station_action = "Mix";
accepted_state = "";        // Accept any state
output_state = "";          // We handle mixing logic manually
requires_cooking = false;   // Instant mixing

// === MIXING SPECIFIC ===
ingredient1 = noone;  // First item placed
ingredient2 = noone;  // Second item placed (if needed)

// Override interact functions for mixing
function interact_place(player) {
    if (player.held_item != noone && instance_exists(player.held_item)) {
        var item = player.held_item;
        
        // Helper to identify ingredient type
        var item_type = "none";
        if (item.object_index == OBJ_LumpiaWrapper) {
            item_type = "wrapper";
        } else if (item.object_index == OBJ_Meat && item.food_type == "sliced") {
            item_type = "sliced_meat";
        } else if (item.object_index == OBJ_Meat && item.food_type == "soy_sliced") {
            item_type = "soy_meat";
        } else if (item.object_index == OBJ_Vegetables && item.veggie_state == "sliced") {
            item_type = "sliced_veggie";
        }
        
        // Not a valid ingredient at all
        if (item_type == "none") {
            return false;
        }
        
        // First ingredient slot - allow any valid ingredient
        if (ingredient1 == noone) {
            ingredient1 = item;
            item.x = x + food_offset_x - 15;
            item.y = y + food_offset_y;
            item.is_held = false;
            item.held_by = noone;
            item.can_slide = false;
            item.velocity_x = 0;
            item.velocity_y = 0;
            player.held_item = noone;
            return true;
        }
        // Second ingredient slot - only allow if it forms a valid combination
        else if (ingredient2 == noone) {
            // Get first ingredient type
            var ing1_type = "none";
            if (ingredient1.object_index == OBJ_LumpiaWrapper) {
                ing1_type = "wrapper";
            } else if (ingredient1.object_index == OBJ_Meat && ingredient1.food_type == "sliced") {
                ing1_type = "sliced_meat";
            } else if (ingredient1.object_index == OBJ_Meat && ingredient1.food_type == "soy_sliced") {
                ing1_type = "soy_meat";
            } else if (ingredient1.object_index == OBJ_Vegetables && ingredient1.veggie_state == "sliced") {
                ing1_type = "sliced_veggie";
            }
            
            // Check valid combinations:
            // wrapper + sliced_meat = Meat Lumpia
            // wrapper + sliced_veggie = Veggie Lumpia
            // soy_meat + sliced_veggie = Caldereta
            var valid_combo = false;
            
            if (ing1_type == "wrapper" && (item_type == "sliced_meat" || item_type == "sliced_veggie")) {
                valid_combo = true;
            } else if (ing1_type == "sliced_meat" && item_type == "wrapper") {
                valid_combo = true;
            } else if (ing1_type == "sliced_veggie" && (item_type == "wrapper" || item_type == "soy_meat")) {
                valid_combo = true;
            } else if (ing1_type == "soy_meat" && item_type == "sliced_veggie") {
                valid_combo = true;
            }
            
            if (!valid_combo) {
                return false;
            }
            
            ingredient2 = item;
            item.x = x + food_offset_x + 15;
            item.y = y + food_offset_y;
            item.is_held = false;
            item.held_by = noone;
            item.can_slide = false;
            item.velocity_x = 0;
            item.velocity_y = 0;
            player.held_item = noone;
            
            // === PERFORM MIXING ===
            mix_ingredients();
            return true;
        }
    }
    return false;
}

function interact_take(player) {
    // Can only take the result after mixing
    if (player.held_item == noone && food_on_station != noone) {
        player.held_item = food_on_station;
        player.held_item.is_held = true;
        player.held_item.held_by = player.id;
        player.held_item.can_slide = true;
        player.held_item.cooking_station = noone;  // Reset so it can be picked up from floor later
        food_on_station = noone;
        return true;
    }
    return false;
}

function mix_ingredients() {
    // Determine what we're mixing
    var has_wrapper = false;
    var has_sliced_meat = false;
    var has_soy_meat = false;
    var has_veggie = false;
    
    // Check ingredient 1
    if (ingredient1.object_index == OBJ_LumpiaWrapper) {
        has_wrapper = true;
    }
    else if (ingredient1.object_index == OBJ_Meat && ingredient1.food_type == "sliced") {
        has_sliced_meat = true;
    }
    else if (ingredient1.object_index == OBJ_Meat && ingredient1.food_type == "soy_sliced") {
        has_soy_meat = true;
    }
    else if (ingredient1.object_index == OBJ_Vegetables && ingredient1.veggie_state == "sliced") {
        has_veggie = true;
    }
    
    // Check ingredient 2
    if (ingredient2.object_index == OBJ_LumpiaWrapper) {
        has_wrapper = true;
    }
    else if (ingredient2.object_index == OBJ_Meat && ingredient2.food_type == "sliced") {
        has_sliced_meat = true;
    }
    else if (ingredient2.object_index == OBJ_Meat && ingredient2.food_type == "soy_sliced") {
        has_soy_meat = true;
    }
    else if (ingredient2.object_index == OBJ_Vegetables && ingredient2.veggie_state == "sliced") {
        has_veggie = true;
    }
    
    // === CALDERETA: soy_sliced meat + sliced veggies ===
    if (has_soy_meat && has_veggie) {
        // Destroy original ingredients
        if (instance_exists(ingredient1)) instance_destroy(ingredient1);
        if (instance_exists(ingredient2)) instance_destroy(ingredient2);
        ingredient1 = noone;
        ingredient2 = noone;
        
        // Create Caldereta
        var result = instance_create_depth(x + food_offset_x, y + food_offset_y, depth - 1, OBJ_Caldereta);
        result.food_type = "raw_caldereta";
        result.sprite_index = spr_rawcaldereta;
        result.plated_sprite = spr_calderetadish;
        
        // Keep it on station
        food_on_station = result;
        result.can_slide = false;
        result.velocity_x = 0;
        result.velocity_y = 0;
        result.is_cooking = false;
        result.cooking_station = id;
        return;
    }
    
    // === LUMPIA: wrapper + filling ===
    if (!has_wrapper) {
        // Invalid mix - no wrapper! Reset station
        if (instance_exists(ingredient1)) ingredient1.can_slide = true;
        if (instance_exists(ingredient2)) ingredient2.can_slide = true;
        ingredient1 = noone;
        ingredient2 = noone;
        return;
    }
    
    // Destroy original ingredients
    if (instance_exists(ingredient1)) instance_destroy(ingredient1);
    if (instance_exists(ingredient2)) instance_destroy(ingredient2);
    ingredient1 = noone;
    ingredient2 = noone;
    
    // Create lumpia result at station position
    var result = instance_create_depth(x + food_offset_x, y + food_offset_y, depth - 1, OBJ_Lumpia);
    
    // CRITICAL: Set the food type BEFORE the Step event runs
    if (has_wrapper && has_sliced_meat) {
        result.food_type = "raw_meat_lumpia";
    } 
    else if (has_wrapper && has_veggie) {
        result.food_type = "raw_veggie_lumpia";
    }
    
    // Manually set sprite (don't wait for Step event)
    if (result.food_type == "raw_meat_lumpia") {
        result.sprite_index = spr_rawmeatlumpia;
        result.plated_sprite = spr_meatlumpiadish;
    } else if (result.food_type == "raw_veggie_lumpia") {
        result.sprite_index = spr_rawveggielumpia;
        result.plated_sprite = spr_veggielumpiadish;
    }
    
    // Keep it on station
    food_on_station = result;
    result.can_slide = false;
    result.velocity_x = 0;
    result.velocity_y = 0;
    result.is_cooking = false;
    result.cooking_station = id;
}