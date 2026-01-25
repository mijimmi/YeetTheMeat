event_inherited();

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
        
        // Check if this is a valid mixing ingredient
        var is_valid = false;
        
        // Valid ingredients: Meat (sliced), Vegetables, Lumpia Wrapper
        if (object_is_ancestor(item.object_index, OBJ_Food)) {
            if (item.object_index == OBJ_Meat && item.food_type == "sliced") {
                is_valid = true;
            }
        } else if (item.object_index == OBJ_Vegetables || item.object_index == OBJ_LumpiaWrapper) {
            is_valid = true;
        }
        
        if (is_valid) {
            // First ingredient slot
            if (ingredient1 == noone) {
                ingredient1 = item;
                item.x = x + food_offset_x - 15; // Offset left for first ingredient
                item.y = y + food_offset_y;
                item.is_held = false;
                item.held_by = noone;
                item.can_slide = false;
                item.velocity_x = 0;
                item.velocity_y = 0;
                player.held_item = noone;
                return true;
            }
            // Second ingredient slot - MIX!
            else if (ingredient2 == noone) {
                ingredient2 = item;
                item.x = x + food_offset_x + 15; // Offset right for second ingredient
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
        food_on_station = noone;
        return true;
    }
    return false;
}

function mix_ingredients() {
    // Determine what we're mixing
    var has_wrapper = false;
    var has_meat = false;
    var has_veggie = false;
    
    // Check ingredient 1
    if (ingredient1.object_index == OBJ_LumpiaWrapper) {
        has_wrapper = true;
    }
    else if (ingredient1.object_index == OBJ_Meat && ingredient1.food_type == "sliced") {
        has_meat = true;
    }
    else if (ingredient1.object_index == OBJ_Vegetables && ingredient1.veggie_state == "sliced") {
        has_veggie = true;
    }
    
    // Check ingredient 2
    if (ingredient2.object_index == OBJ_LumpiaWrapper) {
        has_wrapper = true;
    }
    else if (ingredient2.object_index == OBJ_Meat && ingredient2.food_type == "sliced") {
        has_meat = true;
    }
    else if (ingredient2.object_index == OBJ_Vegetables && ingredient2.veggie_state == "sliced") {
        has_veggie = true;
    }
    
    // Must have wrapper + filling
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
    if (has_wrapper && has_meat) {
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