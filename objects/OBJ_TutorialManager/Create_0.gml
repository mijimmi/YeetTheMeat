// === TUTORIAL STATE ===
tutorial_step = 0;
tutorial_complete = false;

// === TUTORIAL PHASES ===
current_phase = "movement"; // "movement", "controls", "recipe", "serve", "complete"

// === MOVEMENT TUTORIAL ===
movement_attempts = 0;
has_moved = false;
movement_complete = false;

// === CONTROLS TUTORIAL ===
has_picked_wrapper = false;
has_placed_wrapper = false; // NEW
has_picked_meat = false;
has_sliced_meat = false;
has_mixed = false;
has_fried = false;
has_plated = false;
has_served_counter = false;
controls_complete = false;

// === CUSTOMER TUTORIAL ===
tutorial_customer = noone;
customer_spawned = false;
customer_served = false;

// === UI ===
instruction_text = "";
instruction_alpha = 0;
target_alpha = 1;

// Box background
box_padding = 20;
box_color = c_black;
box_alpha = 0.8;

// Text settings
text_color = c_white;
highlight_color = c_yellow;

// Position
instruction_x = display_get_gui_width() / 2;
instruction_y = 100;

// === TRACKING PLAYER ACTIONS ===
player = instance_find(OBJ_P1, 0);

// === FUNCTIONS ===
function set_instruction(text) {
    instruction_text = text;
    target_alpha = 1;
}

function clear_instruction() {
    target_alpha = 0;
}

function advance_step() {
    tutorial_step++;
    update_tutorial();
}

function check_player_action() {
    if (!instance_exists(player)) return;
    
    switch (current_phase) {
        case "movement":
            check_movement_tutorial();
            break;
        case "controls":
            check_controls_info();
            break;
        case "recipe":
            check_recipe_tutorial();
            break;
        case "serve":
            check_serve_tutorial();
            break;
    }
}

function check_movement_tutorial() {
    // Step event
}

function check_controls_info() {
    // Just showing info - advance after 5 seconds
    if (tutorial_step == 0) {
        alarm[0] = 300; // 5 seconds
        tutorial_step = 1; // Prevent re-triggering
    }
}

function check_recipe_tutorial() {
    // Step 0: Pick up lumpia wrapper
    if (tutorial_step == 0) {
        if (player.held_item != noone && player.held_item.object_index == OBJ_LumpiaWrapper) {
            has_picked_wrapper = true;
            advance_step(); // Immediately advance
        }
    }
    // Step 1: Place lumpia wrapper in mixing station (NEW STEP)
	else if (tutorial_step == 1) {
	    // Check if player no longer has the wrapper (they placed it somewhere)
	    if (has_picked_wrapper && player.held_item == noone) {
	        has_placed_wrapper = true;
	        tutorial_step++;
	        update_tutorial();
	    }
	}
    // Step 2: Pick up meat from storage
    else if (tutorial_step == 2) {
        if (player.held_item != noone && player.held_item.object_index == OBJ_Meat) {
            has_picked_meat = true;
            advance_step(); // Immediately advance
        }
    }
    // Step 3: Place meat on slicing station
    else if (tutorial_step == 3) {
        if (instance_exists(OBJ_SlicingStation)) {
            var slicer = instance_find(OBJ_SlicingStation, 0);
            if (slicer.food_on_station != noone) {
                var food = slicer.food_on_station;
                if (food.object_index == OBJ_Meat) {
                    advance_step(); // Advance when placed
                }
            }
        }
    }
    // Step 4: Wait for meat to be sliced, then take it
    else if (tutorial_step == 4) {
        if (instance_exists(OBJ_SlicingStation)) {
            var slicer = instance_find(OBJ_SlicingStation, 0);
            if (slicer.food_on_station != noone) {
                var food = slicer.food_on_station;
                if (food.food_type == "sliced") {
                    has_sliced_meat = true;
                    advance_step(); // Advance when sliced
                }
            }
        }
    }
    // Step 5: Pick up sliced meat
    else if (tutorial_step == 5) {
        if (player.held_item != noone && player.held_item.object_index == OBJ_Meat && player.held_item.food_type == "sliced") {
            advance_step(); // Immediately advance
        }
    }
    // Step 6: Mix ingredients (place on mixing station)
    else if (tutorial_step == 6) {
        if (instance_exists(OBJ_MixingStation)) {
            var mixer = instance_find(OBJ_MixingStation, 0);
            if (mixer.food_on_station != noone && mixer.food_on_station.object_index == OBJ_Lumpia) {
                has_mixed = true;
                advance_step(); // Immediately advance
            }
        }
    }
    // Step 7: Pick up raw lumpia
    else if (tutorial_step == 7) {
        if (player.held_item != noone && player.held_item.object_index == OBJ_Lumpia) {
            advance_step(); // Immediately advance
        }
    }
    // Step 8: Place lumpia on frying station
    else if (tutorial_step == 8) {
        if (instance_exists(OBJ_FryingStation)) {
            var fryer = instance_find(OBJ_FryingStation, 0);
            if (fryer.food_on_station != noone && fryer.food_on_station.object_index == OBJ_Lumpia) {
                advance_step(); // Advance when placed
            }
        }
    }
    // Step 9: Wait for lumpia to cook
    else if (tutorial_step == 9) {
        if (instance_exists(OBJ_FryingStation)) {
            var fryer = instance_find(OBJ_FryingStation, 0);
            if (fryer.food_on_station != noone && fryer.food_on_station.object_index == OBJ_Lumpia) {
                if (fryer.food_on_station.food_type == "cooked_meat_lumpia") {
                    has_fried = true;
                    advance_step(); // Advance when cooked
                }
            }
        }
    }
    // Step 10: Pick up cooked lumpia
    else if (tutorial_step == 10) {
        if (player.held_item != noone && player.held_item.object_index == OBJ_Lumpia && player.held_item.food_type == "cooked_meat_lumpia") {
            advance_step(); // Immediately advance
        }
    }
    // Step 11: Get plate and combine with food
	else if (tutorial_step == 11) {
	    // Check if player is holding a plate with food
	    if (player.held_item != noone && player.held_item.object_index == OBJ_Plate && player.held_item.has_food) {
	        has_plated = true;
	        advance_step(); // Immediately advance to step 12
	    }
	    // OR check if there's a plate on the serving counter with food
	    else if (instance_exists(OBJ_ServingCounter)) {
	        var counter = instance_find(OBJ_ServingCounter, 0);
	        if (counter.plate_on_counter != noone && counter.plate_on_counter.object_index == OBJ_Plate && counter.plate_on_counter.has_food) {
	            show_debug_message("Plate with food already on counter - skipping to serve phase!");
	            has_plated = true;
	            has_served_counter = true;
	            tutorial_step = 0; // Reset step for serve phase
	            current_phase = "serve"; // CHANGE PHASE NOW
	            update_tutorial();
	            alarm[1] = 1; // Spawn customer almost immediately
	        }
	    }
	}
	// Step 12: Place on serving counter
	else if (tutorial_step == 12) {
	    show_debug_message("Step 12: Checking serving counter...");
	    if (instance_exists(OBJ_ServingCounter)) {
	        var counter = instance_find(OBJ_ServingCounter, 0);
	        show_debug_message("Counter found. Plate on counter: " + string(counter.plate_on_counter));
        
	        if (counter.plate_on_counter != noone) {
	            show_debug_message("Plate has food: " + string(counter.plate_on_counter.has_food));
	            if (counter.plate_on_counter.has_food) {
	                show_debug_message("Advancing to step 13 and setting alarm[1]");
	                has_served_counter = true;
	                tutorial_step = 13; // Directly set to 13
	                update_tutorial();
	                alarm[1] = 1; // Spawn customer almost immediately
	            }
	        } else {
	            // Alternative check: player released the plated food
	            if (has_plated && player.held_item == noone && !has_served_counter) {
	                show_debug_message("Player released plate - advancing to step 13 and changing to serve phase");
	                has_served_counter = true;
	                tutorial_step = 0; // Reset step for serve phase
	                current_phase = "serve"; // CHANGE PHASE NOW
	                update_tutorial();
	                alarm[1] = 1; // Spawn customer almost immediately
	            }
	        }
	    }
	}
}

function check_serve_tutorial() {
    // Step 0: Customer is spawned, waiting for serve
    if (tutorial_step == 0 && customer_spawned) {
        // Check if customer still exists before accessing it
        if (instance_exists(tutorial_customer) && tutorial_customer.has_been_served && !customer_served) {
            show_debug_message("Customer has been served! Advancing to complete...");
            customer_served = true;
            tutorial_step = 1; // Advance to step 1
            update_tutorial(); // This will trigger the complete phase
        }
    }
}

function update_tutorial() {
    switch (current_phase) {
        case "movement":
            update_movement_tutorial();
            break;
        case "controls":
            update_controls_tutorial();
            break;
        case "recipe":
            update_recipe_tutorial();
            break;
        case "serve":
            update_serve_tutorial();
            break;
        case "complete":
            set_instruction("Tutorial Complete! Press START to return to main menu.");
            break;
    }
}

function update_movement_tutorial() {
    if (tutorial_step == 0) {
        set_instruction("MOVEMENT: Flick or hold the Left Stick in the opposite direction\nof where you want to go. Release to launch!");
    }
    else if (tutorial_step == 1) {
        set_instruction("Time the power bar:\nRED zone - Long distance\nGREEN zone - Short distance\nPress B to cancel!");
    }
    else {
        // Movement phase complete
        current_phase = "controls";
        tutorial_step = 0;
        update_tutorial(); // Immediately show controls
    }
}

function update_controls_tutorial() {
    if (tutorial_step == 0) {
        set_instruction("CONTROLS:\nX- Take or Pickup objects\nA - Place items on stations or counter\nY - Drop items anywhere");
    }
    else {
        // Controls phase complete
        current_phase = "recipe";
        tutorial_step = 0;
        update_tutorial(); // Immediately start recipe
    }
}

function update_recipe_tutorial() {
    switch (tutorial_step) {
        case 0:
            set_instruction("Step 1: Pick up a Lumpia Wrapper\nPress -X- near the wrapper storage");
            break;
        case 1:
            set_instruction("Step 2: Place wrapper in mixing station\nPress -A- near the mixing station");
            break;
        case 2:
            set_instruction("Step 3: Pick up Meat from storage\nPress -X- near the freezer");
            break;
        case 3:
            set_instruction("Step 4: Place meat on Slicing Station\nPress -A- near the slicing station");
            break;
        case 4:
            set_instruction("Step 5: Wait for meat to slice...");
            break;
        case 5:
            set_instruction("Step 6: Take the sliced meat\nPress -X- near the slicing station");
            break;
        case 6:
            set_instruction("Step 7: Place sliced meat in mixing station\nPress -A- near the mixing station to combine");
            break;
        case 7:
            set_instruction("Step 8: Take the raw lumpia\nPress -X- near the mixing station");
            break;
        case 8:
            set_instruction("Step 9: Place lumpia on Frying Station\nPress -A- near the frying station");
            break;
        case 9:
            set_instruction("Step 10: Wait for lumpia to cook...");
            break;
        case 10:
            set_instruction("Step 11: Take the cooked lumpia\nPress -X- near the frying station");
            break;
        case 11:
            set_instruction("Step 12: Get a plate and combine with lumpia\nPress -X- at plate storage, then -A- near lumpia");
            break;
        case 12:
            set_instruction("Step 13: Place on serving counter\nPress -A- near the serving counter");
            break;
    }
}

function update_serve_tutorial() {
    show_debug_message("update_serve_tutorial called, step: " + string(tutorial_step));
    if (tutorial_step == 0) {
        set_instruction("Serve the Meat Lumpia to the customer!\nPick up the plate -X- and press -A- near the customer.");
    }
    else if (tutorial_step == 1) {
        show_debug_message("Setting phase to complete!");
        // Tutorial complete!
        current_phase = "complete";
        tutorial_complete = true;
        clear_instruction(); // Clear the normal instruction
    }
}

// Start tutorial
update_tutorial();