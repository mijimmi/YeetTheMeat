// Step Event
// Check for pause input
if (keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_start) || gamepad_button_check_pressed(1, gp_start)) {
    if (!paused && !unpausing) {
        // Pause the game
        paused = true;
        unpausing = false;
        pause_anim_y = 300;  // Start below screen
        pause_anim_alpha = 0;
        instance_deactivate_all(true);
        instance_activate_object(OBJ_PauseController);
        instance_activate_object(OBJ_CamController);
        
        // Capture screenshot
        if (surface_exists(pause_surf)) {
            surface_free(pause_surf);
        }
        pause_surf = surface_create(display_get_gui_width(), display_get_gui_height());
        surface_set_target(pause_surf);
        draw_clear_alpha(c_black, 0);
        surface_reset_target();
    } else if (paused && !unpausing) {
        // Start unpause animation (slide down)
        unpausing = true;
    }
}

// Animate pause menu
if (paused) {
    if (unpausing) {
        // Slide down animation
        pause_anim_y = lerp(pause_anim_y, 400, pause_anim_speed);
        pause_anim_alpha = lerp(pause_anim_alpha, 0, pause_anim_speed);
        
        // When animation is done, actually unpause
        if (pause_anim_y > 350) {
        paused = false;
            unpausing = false;
        instance_activate_all();
        if (surface_exists(pause_surf)) {
            surface_free(pause_surf);
        }
    }
    } else {
        // Slide up animation
        pause_anim_y = lerp(pause_anim_y, 0, pause_anim_speed);
        pause_anim_alpha = lerp(pause_anim_alpha, 1, pause_anim_speed);
    }
}

// Handle input when paused (but not during unpause animation)
if (paused && !unpausing) {
    // Navigation cooldown
    if (nav_cooldown > 0) {
        nav_cooldown--;
    }
    
    // Keyboard navigation
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        selected_button = max(0, selected_button - 1);
        nav_cooldown = nav_cooldown_max;
    }
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        selected_button = min(2, selected_button + 1);
        nav_cooldown = nav_cooldown_max;
    }
    
    // Gamepad navigation (with cooldown)
    if (nav_cooldown <= 0) {
        var axis_v0 = gamepad_axis_value(0, gp_axislv);
        var axis_v1 = gamepad_axis_value(1, gp_axislv);
        
        if (axis_v0 < -0.5 || axis_v1 < -0.5 ||
        gamepad_button_check_pressed(0, gp_padu) || gamepad_button_check_pressed(1, gp_padu)) {
            selected_button = max(0, selected_button - 1);
            nav_cooldown = nav_cooldown_max;
    }
        if (axis_v0 > 0.5 || axis_v1 > 0.5 ||
        gamepad_button_check_pressed(0, gp_padd) || gamepad_button_check_pressed(1, gp_padd)) {
            selected_button = min(2, selected_button + 1);
            nav_cooldown = nav_cooldown_max;
        }
    }
    
    // Button activation
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) ||
        gamepad_button_check_pressed(0, gp_face1) || gamepad_button_check_pressed(1, gp_face1)) {
        
        if (selected_button == 0) {
            // Resume - start slide down animation
            unpausing = true;
        } else if (selected_button == 1) {
            // Restart room (instant)
            paused = false;
            instance_activate_all();
            if (surface_exists(pause_surf)) {
                surface_free(pause_surf);
            }
            room_restart();
        } else if (selected_button == 2) {
            // Exit game
            game_end();
        }
    }
    
    // Mouse input (for GUI)
    var gui_width = display_get_gui_width();
    var gui_height = display_get_gui_height();
    var center_x = gui_width / 2;
    var center_y = gui_height / 2;
    
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    
    // Check resume button
    if (point_in_rectangle(mx, my, 
        center_x - button_width / 2, 
        center_y + resume_y_offset - button_height / 2,
        center_x + button_width / 2, 
        center_y + resume_y_offset + button_height / 2)) {
        button_hover = 0;
        if (mouse_check_button_pressed(mb_left)) {
            paused = false;
            instance_activate_all();
            if (surface_exists(pause_surf)) {
                surface_free(pause_surf);
            }
        }
    }
    // Check restart button
    else if (point_in_rectangle(mx, my, 
        center_x - button_width / 2, 
        center_y + restart_y_offset - button_height / 2,
        center_x + button_width / 2, 
        center_y + restart_y_offset + button_height / 2)) {
        button_hover = 1;
        if (mouse_check_button_pressed(mb_left)) {
            paused = false;
            instance_activate_all();
            if (surface_exists(pause_surf)) {
                surface_free(pause_surf);
            }
            room_restart();
        }
    } else {
        button_hover = -1;
    }
}