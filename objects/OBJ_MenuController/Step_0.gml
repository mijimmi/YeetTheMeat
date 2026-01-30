// === UPDATE TITLE ANIMATION ===
title_time += 1;

// === MUSIC FADE OUT ===
if (is_fading_out) {
    var current_gain = audio_sound_get_gain(____BGM_Pops_up_the_mind_wings_MusMus___BLPj3Fh9n1w_);
    var new_gain = max(0, current_gain - fade_out_speed);
    audio_sound_gain(____BGM_Pops_up_the_mind_wings_MusMus___BLPj3Fh9n1w_, new_gain, 0);
    
    // When fully faded out, stop the sound and go to game room
    if (new_gain <= 0) {
        audio_stop_sound(____BGM_Pops_up_the_mind_wings_MusMus___BLPj3Fh9n1w_);
        room_goto(game_room);
    }
    // Don't process any other input while fading
    exit;
}

// === UPDATE BUTTON POP ANIMATION ===
if (menu_state == "main") {
    for (var i = 0; i < total_buttons; i++) {
        var target = (i == selected_button) ? button_target_scale : button_normal_scale;
        button_scales[i] += (target - button_scales[i]) * button_scale_speed;
    }
} else if (menu_state == "mode_select") {
    for (var i = 0; i < total_mode_buttons; i++) {
        var target = (i == selected_mode) ? button_target_scale : button_normal_scale;
        mode_button_scales[i] += (target - mode_button_scales[i]) * button_scale_speed;
    }
} else if (menu_state == "leaderboard") {
    var target = button_target_scale;
    leaderboard_back_scale += (target - leaderboard_back_scale) * button_scale_speed;
    
    // Animate paw moving up from bottom
    if (leaderboard_paw_y > leaderboard_paw_target_y) {
        leaderboard_paw_y -= leaderboard_paw_speed;
        // Clamp to target to prevent overshooting
        if (leaderboard_paw_y < leaderboard_paw_target_y) {
            leaderboard_paw_y = leaderboard_paw_target_y;
        }
    }
    
    // Update bobbing timer
    leaderboard_paw_bob_timer += leaderboard_paw_bob_speed;
    
    // Update title animation timer
    leaderboard_title_timer += 1;
}

// === INPUT HANDLING ===
if (input_cooldown > 0) {
    input_cooldown--;
}

// Check for gamepad connection
if (gamepad == -1) {
    for (var i = 0; i < gamepad_get_device_count(); i++) {
        if (gamepad_is_connected(i)) {
            gamepad = i;
            break;
        }
    }
}

// Navigation input (keyboard and gamepad)
var move_up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var move_down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var move_left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
var move_right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
var confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var go_back = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace);

// Gamepad input
if (gamepad != -1 && gamepad_is_connected(gamepad)) {
    // D-pad and stick
    var gp_up = gamepad_button_check_pressed(gamepad, gp_padu) || 
                (gamepad_axis_value(gamepad, gp_axislv) < -0.5 && input_cooldown == 0);
    var gp_down = gamepad_button_check_pressed(gamepad, gp_padd) || 
                  (gamepad_axis_value(gamepad, gp_axislv) > 0.5 && input_cooldown == 0);
    var gp_left = gamepad_button_check_pressed(gamepad, gp_padl) || 
                  (gamepad_axis_value(gamepad, gp_axislh) < -0.5 && input_cooldown == 0);
    var gp_right = gamepad_button_check_pressed(gamepad, gp_padr) || 
                   (gamepad_axis_value(gamepad, gp_axislh) > 0.5 && input_cooldown == 0);
    var gp_confirm = gamepad_button_check_pressed(gamepad, gp_face1); // A button
    var gp_back = gamepad_button_check_pressed(gamepad, gp_face2);    // B button
    
    move_up = move_up || gp_up;
    move_down = move_down || gp_down;
    move_left = move_left || gp_left;
    move_right = move_right || gp_right;
    confirm = confirm || gp_confirm;
    go_back = go_back || gp_back;
    
    // Set cooldown for analog stick
    if (abs(gamepad_axis_value(gamepad, gp_axislv)) > 0.5 || 
        abs(gamepad_axis_value(gamepad, gp_axislh)) > 0.5) {
        input_cooldown = input_delay;
    }
}

// === MAIN MENU STATE ===
if (menu_state == "main") {
    // Move selection
    if (move_up) {
        selected_button--;
        if (selected_button < 0) selected_button = total_buttons - 1;
    }
    if (move_down) {
        selected_button++;
        if (selected_button >= total_buttons) selected_button = 0;
    }
    
    // Play hover sound if button changed
    if (selected_button != previous_button) {
        audio_play_sound(sfx_hover, 1, false);
        previous_button = selected_button;
    }
    
    // Confirm selection
    if (confirm) {
        audio_sound_gain(sfx_confirm, 0.6, 0);
        audio_play_sound(sfx_confirm, 1, false);
        switch (selected_button) {
            case 0: // Start -> Go to mode select
                menu_state = "mode_select";
                selected_mode = 0;
                // Reset mode button scales
                mode_button_scales = [1, 1, 1];
                break;
            case 1: // Leaderboard
                menu_state = "leaderboard";
                leaderboard_back_scale = 1;
                // Reset paw animation to start from bottom
                leaderboard_paw_y = 1080;
                break;
            case 2: // Exit
                game_end();
                break;
        }
    }
}
// === MODE SELECT STATE ===
else if (menu_state == "mode_select") {
    // Left/Right for Singleplayer/Multiplayer, Down for Go Back
    if (move_left) {
        if (selected_mode == 1) selected_mode = 0; // Multiplayer -> Singleplayer
        else if (selected_mode == 2) selected_mode = 0; // Go Back -> Singleplayer
    }
    if (move_right) {
        if (selected_mode == 0) selected_mode = 1; // Singleplayer -> Multiplayer
        else if (selected_mode == 2) selected_mode = 1; // Go Back -> Multiplayer
    }
    if (move_down) {
        if (selected_mode != 2) selected_mode = 2; // Go to Go Back
    }
    if (move_up) {
        if (selected_mode == 2) selected_mode = 0; // Go Back -> Singleplayer
    }
    
    // Play hover sound if mode changed
    if (selected_mode != previous_mode) {
        audio_play_sound(sfx_hover, 1, false);
        previous_mode = selected_mode;
    }
    
    // Go back with B/Escape
    if (go_back) {
        audio_sound_gain(sfx_confirm, 0.6, 0);
        audio_play_sound(sfx_confirm, 1, false);
        menu_state = "main";
    }
    
    // Confirm selection
    if (confirm) {
        audio_sound_gain(sfx_confirm, 0.6, 0);
        audio_play_sound(sfx_confirm, 1, false);
        switch (selected_mode) {
            case 0: // Singleplayer
                global.game_mode = "singleplayer";
                global.show_cutscene = true;  // Trigger intro cutscene
                global.show_tutorial = true;  // NEW: Show tutorial after cutscene
                // Start fade out (room transition happens when fade completes)
                is_fading_out = true;
                break;
            case 1: // Multiplayer
                global.game_mode = "multiplayer";
                global.show_cutscene = true;  // Trigger intro cutscene
                global.show_tutorial = true;  // NEW: Show tutorial after cutscene
                // Start fade out (room transition happens when fade completes)
                is_fading_out = true;
                break;
            case 2: // Go Back
                menu_state = "main";
                break;
        }
    }
}
// === LEADERBOARD STATE ===
else if (menu_state == "leaderboard") {
    // Go back with B/Escape or confirm
    if (go_back || confirm) {
        audio_sound_gain(sfx_confirm, 0.6, 0);
        audio_play_sound(sfx_confirm, 1, false);
        menu_state = "main";
        // Reset paw position when leaving leaderboard
        leaderboard_paw_y = 1080;
    }
}
