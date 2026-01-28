interact_range = 85;

// Counter holds ONE plate at a time (for assembly)
plate_on_counter = noone;

// Visual positioning
counter_offset_y = 0; // Height where plate sits on counter

// === INTERACTION FUNCTIONS ===
function interact_place(player) {
    // Place empty plate
    if (player.held_item != noone && instance_exists(player.held_item) && player.held_item.object_index == OBJ_Plate) {
        if (plate_on_counter == noone) {
            var plate = player.held_item;
            plate_on_counter = plate;
            plate.is_held = false;
            plate.held_by = noone;
            plate.can_slide = false;
            
            if (plate.has_food && plate.food_on_plate != noone && instance_exists(plate.food_on_plate)) {
                plate.food_on_plate.can_slide = false;
            }
            
            player.held_item = noone;
            return true;
        }
    }
    // Plate food on counter
    // Plate food on counter
	else if (player.held_item != noone && instance_exists(player.held_item) && object_is_ancestor(player.held_item.object_index, OBJ_Food)) {
	    if (plate_on_counter != noone && !plate_on_counter.has_food) {
	        var food = player.held_item;
	        var plate = plate_on_counter;
        
	        // Check if food is ready to be plated (any cooked state)
	        var is_ready_to_plate = (
	            food.food_type == "cooked" ||
	            food.food_type == "fried_pork" ||
	            food.food_type == "adobo" ||
	            food.food_type == "cooked_meat_lumpia" ||
	            food.food_type == "cooked_veggie_lumpia" ||
	            food.food_type == "cooked_caldereta"
	        );
        
	        if (is_ready_to_plate) {
	            plate.food_on_plate = food;
	            plate.has_food = true;
	            food.is_held = false;
	            food.held_by = noone;
	            food.is_on_plate = true;
	            food.plate_instance = plate;
	            food.can_slide = false;
            
	            player.held_item = noone; // ← This clears the held item
	            return true;
	        }
	    }
	}
    return false;
}

function interact_take(player) {
    // Take plate from counter
    if (player.held_item == noone && plate_on_counter != noone) {
        var plate = plate_on_counter;
        
        if (instance_exists(plate)) {
            player.held_item = plate;
            plate.is_held = true;
            plate.held_by = player.id;
            plate.can_slide = true;
            
            if (plate.has_food && plate.food_on_plate != noone && instance_exists(plate.food_on_plate)) {
                plate.food_on_plate.can_slide = true;
            }
            
            plate_on_counter = noone;
            return true;
        }
    }
    return false;
}