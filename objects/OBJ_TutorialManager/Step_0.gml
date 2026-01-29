// Update instruction fade
instruction_alpha = lerp(instruction_alpha, target_alpha, 0.1);

// Update arrow bounce animation
arrow_bounce += 0.15;

// === CHECK FOR SKIP TUTORIAL (SELECT BUTTON) - Either player can skip ===
if (current_phase != "complete") { // Only allow skip if not already complete
    if (gamepad_button_check_pressed(0, gp_select) || gamepad_button_check_pressed(1, gp_select) || keyboard_check_pressed(vk_tab)) { // SELECT button from P1 or P2
        show_debug_message("Tutorial skipped!");
        global.game_paused = false;
        global.show_tutorial = false;  // Don't show tutorial again (NEW)
        room_goto(game_room); // Replace 'game_room' with your actual main game room name
        exit;
    }
}

// Check both players exist
if (!instance_exists(player)) {
    player = instance_find(OBJ_P1, 0);
    if (!instance_exists(player)) {
        player = instance_find(OBJ_P2, 0); // Fallback to P2
    }
}
if (!instance_exists(player)) return;

// === TUTORIAL COMPLETE - PAUSE AND WAIT FOR INPUT ===
if (current_phase == "complete") {
    // Pause the game
    global.game_paused = true;
    
    // Check for A button press to start game (either player)
    if (gamepad_button_check_pressed(0, global.btn_place) || gamepad_button_check_pressed(1, global.btn_place) || keyboard_check_pressed(ord("C"))) { // A button from P1 or P2
        // Unpause and go to main game room
        global.game_paused = false;
        global.show_tutorial = false;  // Don't show tutorial again (NEW)
        room_goto(game_room); // Replace 'game_room' with your actual main game room name
    }
    
    // Don't process any other tutorial logic
    exit;
}

// === MOVEMENT PHASE ===
if (current_phase == "movement") {
    // Step 0: First movement
    if (tutorial_step == 0) {
        if (player.state == "moving" && !has_moved) {
            has_moved = true;
            alarm[0] = 90; // Wait 1.5 seconds before showing step 2
        }
    }
    // Step 1: Second movement (with power bar info)
    else if (tutorial_step == 1) {
        if (player.state == "moving" && has_moved) {
            movement_complete = true;
            alarm[0] = 90; // Brief delay, then move to controls
        }
    }
}

// === CONTROLS PHASE ===
else if (current_phase == "controls") {
    // Track button presses from either player
    var pressed_X = gamepad_button_check_pressed(0, global.btn_take) || gamepad_button_check_pressed(1, global.btn_take) || keyboard_check_pressed(ord("Z"));
    var pressed_A = gamepad_button_check_pressed(0, global.btn_place) || gamepad_button_check_pressed(1, global.btn_place) || keyboard_check_pressed(ord("C"));
    var pressed_Y = gamepad_button_check_pressed(0, global.btn_drop) || gamepad_button_check_pressed(1, global.btn_drop) || keyboard_check_pressed(ord("X"));
    
    // Advance when any button has been pressed
    if (pressed_X || pressed_A || pressed_Y) {
        alarm[0] = 180; // Wait 3 seconds, then move to recipe phase
    }
}

// === RECIPE PHASE ===
else if (current_phase == "recipe") {
    check_recipe_tutorial();
}

// === SERVE PHASE ===
else if (current_phase == "serve") {
    check_serve_tutorial();
}