// === DEVICE-AWARE BUTTON LABELS ===
// Show keyboard keys if the tutorial player is on keyboard, else controller labels
function tut_on_keyboard() {
    var p = instance_exists(OBJ_P1) ? instance_find(OBJ_P1, 0) : noone;
    if (p != noone && variable_instance_exists(p, "prompt_use_keyboard")) {
        return p.prompt_use_keyboard;
    }
    return !(gamepad_is_connected(0) || gamepad_is_connected(1));
}
function tut_action_key() {
    return tut_on_keyboard() ? "E" : "X";
}
function tut_drop_key() {
    return tut_on_keyboard() ? "R" : "Y";
}
function tut_select_key() {
    return tut_on_keyboard() ? "TAB" : "SELECT";
}
function tut_all_action_keys() {
    // Action word instead of raw button labels
    return "Interact";
}
function tut_all_drop_keys() {
    // Action word instead of raw button labels
    return "Drop";
}

// === TUTORIAL STATE ===
tutorial_step = 0;
tutorial_complete = false;

// === TUTORIAL PHASES ===
current_phase = "movement"; // "movement", "controls", "recipe", "serve", "complete"

// === MUSIC ===
// Play tutorial music with fade-in
if (!audio_is_playing(Under_the_Cobblestone_watson)) {
    audio_play_sound(Under_the_Cobblestone_watson, 1, true);
    audio_sound_gain(Under_the_Cobblestone_watson, 0, 0); // Start at 0
    audio_sound_gain(Under_the_Cobblestone_watson, 0.18, 2000); // Fade to 18% over 2 seconds (matches cutscene)
}

// Music info for display
song_title = "Under the Cobblestone";
song_artist = "watson";

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
instruction_text_full = ""; // Full text to display
instruction_text_display = ""; // Text being typed out
instruction_char_index = 0;
instruction_type_timer = 0;
instruction_type_speed = 1; // Frames between each character (faster than cutscene)
instruction_text_complete = false;
instruction_alpha = 0;
target_alpha = 1;

// === COMPLETE SCREEN TYPING ===
complete_text_full = "You are ready to cook!";
complete_text_display = "";
complete_char_index = 0;
complete_type_timer = 0;
complete_type_speed = 2; // Slower for dramatic effect
complete_text_complete = false;

continue_text_full = "Press any key to proceed to your shift!";
continue_text_display = "";
continue_char_index = 0;
continue_type_timer = 0;
continue_type_speed = 1;
continue_text_complete = false;

reminder_text_full = "Tip: Open the recipe book anytime with " + tut_select_key() + "!";
reminder_text_display = "";
reminder_char_index = 0;
reminder_type_timer = 0;
reminder_type_speed = 1;
reminder_text_complete = false;

warning_text_full = "Watch out for collisions!";
warning_text_display = "";
warning_char_index = 0;
warning_type_timer = 0;
warning_type_speed = 1;
warning_text_complete = false;

warning_subtext_full = "Bumping into people makes you drop your food!";
warning_subtext_display = "";
warning_subtext_char_index = 0;
warning_subtext_type_timer = 0;
warning_subtext_type_speed = 1;
warning_subtext_complete = false;

// Box background (cute cream "recipe card" look)
box_padding = 28;
box_color = make_color_rgb(250, 241, 218);      // warm cream
box_alpha = 0.97;

// Text settings
text_color = make_color_rgb(90, 55, 30);        // dark brown ink
highlight_color = make_color_rgb(124, 82, 46);  // brown border

// Gentle idle bob so the card feels alive
box_bob_timer = 0;

// === TUTORIAL COMPLETE SCREEN ANIMATIONS ===
complete_card_y_offset = 300;   // Starts below screen, slides up
complete_card_target_y = 0;     // Final resting position
complete_headline_scale = 0.5;  // Starts small, pops to full
complete_headline_timer = 0;    // Drives pulse after pop
complete_star_timer = 0;        // Sparkle animation timer
complete_prompt_blink = 0;      // Blink timer for continue prompt

// Failsafe timer so the controls screen can't soft-lock an idle player
controls_idle_timer = 0;
controls_anim_timer = 0;

// Position
instruction_x = display_get_gui_width() / 2;
instruction_y = 100;

// Tutorial arrow indicators
tutorial_target_station = noone; // Which station to highlight
arrow_bounce = 0; // Animation timer for arrow

// === TRACKING PLAYER ACTIONS (Check both players) ===
player = instance_find(OBJ_P1, 0);
if (!instance_exists(player)) {
    player = instance_find(OBJ_P2, 0); // If P1 doesn't exist, track P2
}

// === FUNCTIONS ===
function set_instruction(text) {
    // Substitute tutorial placeholders
    // -X- and -Y- now show all valid options for P1 and P2.
    text = string_replace_all(text, "-X-", tut_all_action_keys());
    text = string_replace_all(text, "-Y-", tut_all_drop_keys());
    text = string_replace_all(text, "-SELECT-", "-" + tut_select_key() + "-");
    instruction_text_full = text;
    instruction_text_display = "";
    instruction_char_index = 0;
    instruction_text_complete = false;
    target_alpha = 1;
}

function clear_instruction() {
    target_alpha = 0;
}

function is_multiplayer_mode() {
    if (variable_global_exists("game_mode") && global.game_mode == "multiplayer") {
        return true;
    }
    return instance_exists(OBJ_P2);
}

// Draws one player's control card with controller + keyboard columns
function draw_control_card(ccx, ccy, cw, ch, title, title_color, rows, a, anim_t, card_index) {
    // Pop-in + idle bob per card
    var pop = min(1, anim_t * 0.06);
    pop = pop + sin(anim_t * 0.08 + card_index * 1.2) * 0.015 * pop;
    var bob = sin(anim_t * 0.05 + card_index * 2.1) * 8 * pop;
    ccy += bob;

    var x1 = ccx - cw / 2;
    var x2 = ccx + cw / 2;
    var y1 = ccy - ch / 2;
    var y2 = ccy + ch / 2;
    var rad = 28;

    // Shadow
    draw_set_alpha(0.22 * a * pop);
    draw_set_color(c_black);
    draw_roundrect_ext(x1 + 7, y1 + 9, x2 + 7, y2 + 9, rad, rad, false);
    // Cream fill
    draw_set_alpha(box_alpha * a);
    draw_set_color(box_color);
    draw_roundrect_ext(x1, y1, x2, y2, rad, rad, false);
    // Brown double border
    draw_set_alpha(a);
    draw_set_color(highlight_color);
    draw_roundrect_ext(x1, y1, x2, y2, rad, rad, true);
    draw_roundrect_ext(x1 + 4, y1 + 4, x2 - 4, y2 - 4, rad - 4, rad - 4, true);

    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // Header pill (player color) — gentle pulse
    var ts = 2.2 * pop;
    var tw = string_width(title) * ts;
    var hp_y = y1 + 48;
    var pill_pulse = 1 + sin(anim_t * 0.06 + card_index) * 0.03;
    draw_set_color(title_color);
    draw_roundrect_ext(ccx - (tw / 2 + 30) * pill_pulse, hp_y - 28, ccx + (tw / 2 + 30) * pill_pulse, hp_y + 28, 20, 20, false);
    draw_set_color(box_color);
    draw_text_transformed(ccx, hp_y, title, ts, ts, 0);

    // Column anchors
    var label_col = x1 + 44;
    var pad_col = x1 + cw * 0.56;
    var key_col = x1 + cw * 0.84;

    // Column sub-headers
    var head_y = hp_y + 68;
    var hs = 1.65 * pop;
    draw_set_color(make_color_rgb(150, 110, 70));
    draw_text_transformed(pad_col, head_y, "PAD", hs, hs, 0);
    draw_text_transformed(key_col, head_y, "KEYS", hs, hs, 0);

    // Divider line
    draw_set_alpha(a * 0.4);
    draw_set_color(highlight_color);
    draw_line_width(x1 + 30, head_y + 24, x2 - 30, head_y + 24, 3);
    draw_set_alpha(a);

    // Rows (staggered fade-in)
    var row_y = head_y + 58;
    var row_gap = 72;
    var rs = 1.85 * pop;
    for (var i = 0; i < array_length(rows); i++) {
        var row_delay = card_index * 12 + i * 10;
        var row_alpha = clamp((anim_t - row_delay) * 0.07, 0, 1) * a;
        if (row_alpha <= 0.01) continue;

        var ry = row_y + i * row_gap;
        draw_set_alpha(row_alpha);

        // Action label (left aligned)
        draw_set_halign(fa_left);
        draw_set_color(text_color);
        draw_text_transformed(label_col, ry, rows[i][0], rs, rs, 0);
        // Pad + keyboard keys (centered in columns)
        draw_set_halign(fa_center);
        draw_set_color(make_color_rgb(70, 45, 25));
        draw_text_transformed(pad_col, ry, rows[i][1], rs, rs, 0);
        draw_text_transformed(key_col, ry, rows[i][2], rs, rs, 0);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
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
    // Check both players for held items
    var p1 = instance_find(OBJ_P1, 0);
    var p2 = instance_find(OBJ_P2, 0);
    
    // Step 0: Pick up lumpia wrapper
    if (tutorial_step == 0) {
        var has_wrapper = false;
        if (instance_exists(p1) && p1.held_item != noone && p1.held_item.object_index == OBJ_LumpiaWrapper) {
            has_wrapper = true;
        }
        if (instance_exists(p2) && p2.held_item != noone && p2.held_item.object_index == OBJ_LumpiaWrapper) {
            has_wrapper = true;
        }
        if (has_wrapper) {
            has_picked_wrapper = true;
            advance_step(); // Immediately advance
        }
    }
    // Step 1: Place lumpia wrapper in mixing station (NEW STEP)
	else if (tutorial_step == 1) {
	    // Check if the wrapper is on the mixing station
	    if (instance_exists(OBJ_MixingStation)) {
	        var mixer = instance_find(OBJ_MixingStation, 0);
	        // Check if ingredient1 is a wrapper
	        if (mixer.ingredient1 != noone && instance_exists(mixer.ingredient1) && mixer.ingredient1.object_index == OBJ_LumpiaWrapper) {
	            has_placed_wrapper = true;
	            tutorial_step++;
	            update_tutorial();
	        }
	    }
	}
    // Step 2: Pick up meat from storage
    else if (tutorial_step == 2) {
        var has_meat = false;
        if (instance_exists(p1) && p1.held_item != noone && p1.held_item.object_index == OBJ_Meat) {
            has_meat = true;
        }
        if (instance_exists(p2) && p2.held_item != noone && p2.held_item.object_index == OBJ_Meat) {
            has_meat = true;
        }
        if (has_meat) {
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
        var has_sliced = false;
        if (instance_exists(p1) && p1.held_item != noone && p1.held_item.object_index == OBJ_Meat && p1.held_item.food_type == "sliced") {
            has_sliced = true;
        }
        if (instance_exists(p2) && p2.held_item != noone && p2.held_item.object_index == OBJ_Meat && p2.held_item.food_type == "sliced") {
            has_sliced = true;
        }
        if (has_sliced) {
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
        var has_lumpia = false;
        if (instance_exists(p1) && p1.held_item != noone && p1.held_item.object_index == OBJ_Lumpia) {
            has_lumpia = true;
        }
        if (instance_exists(p2) && p2.held_item != noone && p2.held_item.object_index == OBJ_Lumpia) {
            has_lumpia = true;
        }
        if (has_lumpia) {
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
        var has_cooked = false;
        if (instance_exists(p1) && p1.held_item != noone && p1.held_item.object_index == OBJ_Lumpia && p1.held_item.food_type == "cooked_meat_lumpia") {
            has_cooked = true;
        }
        if (instance_exists(p2) && p2.held_item != noone && p2.held_item.object_index == OBJ_Lumpia && p2.held_item.food_type == "cooked_meat_lumpia") {
            has_cooked = true;
        }
        
        // SHORTCUT: player instant-plated at station - holding a plate with cooked lumpia
        var has_plated_already = false;
        if (instance_exists(p1) && p1.held_item != noone && p1.held_item.object_index == OBJ_Plate && p1.held_item.has_food) {
            has_plated_already = true;
        }
        if (instance_exists(p2) && p2.held_item != noone && p2.held_item.object_index == OBJ_Plate && p2.held_item.has_food) {
            has_plated_already = true;
        }
        
        if (has_plated_already) {
            // Skip steps 11 and 12 of recipe phase — go straight to "place on counter"
            has_plated = true;
            tutorial_step = 12;
            update_tutorial();
        } else if (has_cooked) {
            advance_step();
        }
    }
    // Step 11: Get plate and combine with food
	else if (tutorial_step == 11) {
	    // Check if either player is holding a plate with food
	    var has_plated_item = false;
	    if (instance_exists(p1) && p1.held_item != noone && p1.held_item.object_index == OBJ_Plate && p1.held_item.has_food) {
	        has_plated_item = true;
	    }
	    if (instance_exists(p2) && p2.held_item != noone && p2.held_item.object_index == OBJ_Plate && p2.held_item.has_food) {
	        has_plated_item = true;
	    }
	    
	    if (has_plated_item) {
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
	                show_debug_message("Advancing to serve phase and setting alarm[1]");
	                has_served_counter = true;
	                tutorial_step = 0; // Reset step for serve phase
	                current_phase = "serve"; // CHANGE PHASE NOW
	                update_tutorial();
	                alarm[1] = 1; // Spawn customer almost immediately
	            }
	        } else {
	            // Alternative check: either player released the plated food
	            var both_empty = (!instance_exists(p1) || p1.held_item == noone) && (!instance_exists(p2) || p2.held_item == noone);
	            if (has_plated && both_empty && !has_served_counter) {
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
        // Drawn as control cards in Draw_64; no typed text needed
        controls_anim_timer = 0;
        set_instruction("");
    }
    else {
        // Controls phase complete
        current_phase = "recipe";
        tutorial_step = 0;
        update_tutorial(); // Immediately start recipe
    }
}

function update_recipe_tutorial() {
    // Reset target station
    tutorial_target_station = noone;
    
    switch (tutorial_step) {
        case 0:
            set_instruction("Step 1: Grab a Lumpia Wrapper\nInteract with the wrapper storage");
            tutorial_target_station = instance_find(OBJ_WrapperStorage, 0);
            break;
        case 1:
            set_instruction("Step 2: Add the wrapper to the mix\nInteract with the mixing station");
            tutorial_target_station = instance_find(OBJ_MixingStation, 0);
            break;
        case 2:
            set_instruction("Step 3: Grab some Meat\nInteract with the freezer");
            tutorial_target_station = instance_find(OBJ_Freezer, 0);
            break;
        case 3:
            set_instruction("Step 4: Slice the meat\nInteract with the slicing station");
            tutorial_target_station = instance_find(OBJ_SlicingStation, 0);
            break;
        case 4:
            set_instruction("Step 5: Wait for the meat to slice...");
            tutorial_target_station = instance_find(OBJ_SlicingStation, 0);
            break;
        case 5:
            set_instruction("Step 6: Grab the sliced meat\nInteract with the slicing station");
            tutorial_target_station = instance_find(OBJ_SlicingStation, 0);
            break;
        case 6:
            set_instruction("Step 7: Combine it in the mix\nInteract with the mixing station");
            tutorial_target_station = instance_find(OBJ_MixingStation, 0);
            break;
        case 7:
            set_instruction("Step 8: Grab the raw lumpia\nInteract with the mixing station");
            tutorial_target_station = instance_find(OBJ_MixingStation, 0);
            break;
        case 8:
            set_instruction("Step 9: Fry the lumpia\nInteract with the frying station");
            tutorial_target_station = instance_find(OBJ_FryingStation, 0);
            break;
        case 9:
            set_instruction("Step 10: Wait for the lumpia to cook...");
            tutorial_target_station = instance_find(OBJ_FryingStation, 0);
            break;
        case 10:
            set_instruction("Step 11: Grab the cooked lumpia\nInteract with the frying station");
            tutorial_target_station = instance_find(OBJ_FryingStation, 0);
            break;
        case 11:
            set_instruction("Step 12: Plate the lumpia\nGrab a plate, or bring cooked food to the plates");
            tutorial_target_station = instance_find(OBJ_PlateStorage, 0);
            break;
        case 12:
            set_instruction("Step 13: Send it out!\nInteract with the serving counter");
            tutorial_target_station = instance_find(OBJ_ServingCounter, 0);
            break;
    }
}

function update_serve_tutorial() {
    show_debug_message("update_serve_tutorial called, step: " + string(tutorial_step));
    if (tutorial_step == 0) {
        set_instruction("Serve the Meat Lumpia to the customer!\nGrab the plate, then Interact with the customer.");
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