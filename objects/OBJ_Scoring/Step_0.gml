// Only process input on results screen
if (!show_results) {
    exit;
}

// Decrease input cooldown
if (input_cooldown > 0) {
    input_cooldown--;
}

// === NAME ENTRY MODE ===
if (entering_name) {
    // Navigate between letters (left/right)
    if (input_cooldown <= 0) {
        var h_input = 0;
        if (keyboard_check_pressed(vk_left) || gamepad_button_check_pressed(0, gp_padl)) {
            h_input = -1;
        } else if (keyboard_check_pressed(vk_right) || gamepad_button_check_pressed(0, gp_padr)) {
            h_input = 1;
        }
        
        if (h_input != 0) {
            name_cursor = (name_cursor + h_input + max_name_length) % max_name_length;
            input_cooldown = input_cooldown_max;
        }
    }
    
    // Change character (up/down)
    if (input_cooldown <= 0) {
        var v_input = 0;
        if (keyboard_check_pressed(vk_up) || gamepad_button_check_pressed(0, gp_padu)) {
            v_input = 1;
        } else if (keyboard_check_pressed(vk_down) || gamepad_button_check_pressed(0, gp_padd)) {
            v_input = -1;
        }
        
        if (v_input != 0) {
            var char_count = string_length(available_chars);
            char_index[name_cursor] = (char_index[name_cursor] + v_input + char_count) % char_count;
            input_cooldown = input_cooldown_max;
        }
    }
    
    // Confirm name (A button)
    if (gamepad_button_check_pressed(0, gp_face1) || keyboard_check_pressed(vk_enter)) {
        // Build final name
        player_name = "";
        for (var i = 0; i < max_name_length; i++) {
            player_name += string_char_at(available_chars, char_index[i] + 1);
        }
        
        // Save to leaderboard
        save_to_leaderboard(player_name, total_score);
        
        entering_name = false;
    }
}
// === NORMAL RESULTS SCREEN ===
else {
    // Always prompt for name entry when results show (for testing, everyone gets on leaderboard)
    if (!variable_instance_exists(id, "checked_leaderboard")) {
        checked_leaderboard = true;
        entering_name = true; // Always allow name entry
    }
    
    // Restart on A button
    if (gamepad_button_check_pressed(0, gp_face1) || keyboard_check_pressed(ord("C"))) {
        room_restart();
    }
    
    // Go to menu on B button
    if (gamepad_button_check_pressed(0, gp_face2) || keyboard_check_pressed(ord("X"))) {
        room_goto(menu_room);
    }
}

function save_to_leaderboard(name, score) {
    // Save to global pending entry - will be picked up when menu loads
    global.pending_leaderboard_entry = [name, score];
    show_debug_message("Saved to leaderboard: " + name + " - " + string(score));
}
