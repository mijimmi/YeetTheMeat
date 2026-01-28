// === UPDATE TITLE ANIMATION ===
title_time += 1;

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
    
    // Confirm selection
    if (confirm) {
        switch (selected_button) {
            case 0: // Start -> Go to mode select
                menu_state = "mode_select";
                selected_mode = 0;
                // Reset mode button scales
                mode_button_scales = [1, 1, 1];
                break;
            case 1: // Leaderboard
                // TODO: Implement leaderboard
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
    
    // Go back with B/Escape
    if (go_back) {
        menu_state = "main";
    }
    
    // Confirm selection
    if (confirm) {
        switch (selected_mode) {
            case 0: // Singleplayer
                global.game_mode = "singleplayer";
                room_goto(game_room);
                break;
            case 1: // Multiplayer
                global.game_mode = "multiplayer";
                room_goto(game_room);
                break;
            case 2: // Go Back
                menu_state = "main";
                break;
        }
    }
}
