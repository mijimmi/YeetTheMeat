// Step Event
// Check for pause input
if (keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_start) || gamepad_button_check_pressed(1, gp_start)) {
    if (!paused) {
        // Pause the game
        paused = true;
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
    } else {
        // Resume the game
        paused = false;
        instance_activate_all();
        if (surface_exists(pause_surf)) {
            surface_free(pause_surf);
        }
    }
}

// Handle input when paused
if (paused) {
    // Keyboard navigation
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        selected_button = 0;
    }
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        selected_button = 1;
    }
    
    // Gamepad navigation
    if (gamepad_axis_value(0, gp_axislv) < -0.5 || gamepad_axis_value(1, gp_axislv) < -0.5 ||
        gamepad_button_check_pressed(0, gp_padu) || gamepad_button_check_pressed(1, gp_padu)) {
        selected_button = 0;
    }
    if (gamepad_axis_value(0, gp_axislv) > 0.5 || gamepad_axis_value(1, gp_axislv) > 0.5 ||
        gamepad_button_check_pressed(0, gp_padd) || gamepad_button_check_pressed(1, gp_padd)) {
        selected_button = 1;
    }
    
    // Button activation
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) ||
        gamepad_button_check_pressed(0, gp_face1) || gamepad_button_check_pressed(1, gp_face1)) {
        
        if (selected_button == 0) {
            // Resume
            paused = false;
            instance_activate_all();
            if (surface_exists(pause_surf)) {
                surface_free(pause_surf);
            }
        } else if (selected_button == 1) {
            // Restart room
            paused = false;
            instance_activate_all();
            if (surface_exists(pause_surf)) {
                surface_free(pause_surf);
            }
            room_restart();
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