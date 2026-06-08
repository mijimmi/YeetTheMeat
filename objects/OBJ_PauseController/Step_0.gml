// Step Event
// Check for pause input (but not during cutscene or scoreboard)
var scoreboard_active = (instance_exists(OBJ_Scoring) && OBJ_Scoring.show_results);
if ((keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_start) || gamepad_button_check_pressed(1, gp_start)) 
    && !instance_exists(OBJ_CutsceneController) && !scoreboard_active && !slice_active) {
    if (!paused && !unpausing) {
        // Play pause sound
        audio_sound_gain(sfx_pause, 0.6, 0);
        audio_play_sound(sfx_pause, 1, false);
        
        // Pause the game
        paused = true;
        unpausing = false;
        pause_anim_y = 300;  // Start below screen
        pause_anim_alpha = 0;
        pause_timer = 0;     // restart the staggered entrance animation
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
        pause_timer++;   // advance staggered entrance + ongoing wobble timing
    }
}

// Advance the confirm "slice" animation; fire the real action when it finishes
if (paused && slice_active) {
    slice_timer++;
    // Keep the slice sfx very short - cut it off right after the slash lands
    if (slice_timer == 8 && slice_snd != -1 && audio_is_playing(slice_snd)) {
        audio_stop_sound(slice_snd);
        slice_snd = -1;
    }
    if (slice_timer >= slice_duration) {
        slice_active = false;
        if (slice_snd != -1 && audio_is_playing(slice_snd)) {
            audio_stop_sound(slice_snd);
        }
        slice_snd = -1;
        var k = slice_kind;
        slice_kind = -1;
        paused = false;
        instance_activate_all();
        if (surface_exists(pause_surf)) {
            surface_free(pause_surf);
        }
        if (k == 1) {
            audio_stop_all();
            room_restart();
        }
    }
}

// Handle input when paused (but not during unpause animation or a slice)
if (paused && !unpausing && !slice_active) {
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
        selected_button = min(3, selected_button + 1);
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
            selected_button = min(3, selected_button + 1);
            nav_cooldown = nav_cooldown_max;
        }
    }
    
    // Play hover sound if selection changed
    if (selected_button != previous_selected) {
        audio_play_sound(sfx_hover, 1, false);
        previous_selected = selected_button;
    }
    
    // Button activation
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) ||
        gamepad_button_check_pressed(0, gp_face1) || gamepad_button_check_pressed(1, gp_face1) ||
        gamepad_button_check_pressed(0, gp_face3) || gamepad_button_check_pressed(1, gp_face3)) {
        
        if (selected_button == 0 || selected_button == 1) {
            // Resume / Restart - kick off the slice animation; the action fires
            // when the slice finishes (see slice-advance block above)
            slice_active = true;
            slice_kind = selected_button;
            slice_timer = 0;
            audio_sound_gain(sfx_slicing, 0.9, 0);
            slice_snd = audio_play_sound(sfx_slicing, 5, false);
            audio_sound_pitch(slice_snd, 1.8);   // snappier
        } else if (selected_button == 2) {
            audio_sound_gain(sfx_confirm, 0.6, 0);
            audio_play_sound(sfx_confirm, 1, false);
            // Back to Menu
            paused = false;
            instance_activate_all();
            if (surface_exists(pause_surf)) {
                surface_free(pause_surf);
            }
            
            // Stop tutorial music if it's playing
            if (audio_is_playing(Under_the_Cobblestone_watson)) {
                audio_stop_sound(Under_the_Cobblestone_watson);
            }
            
            // Stop all game room music
            if (audio_is_playing(Magic_Cooking___watson)) {
                audio_stop_sound(Magic_Cooking___watson);
            }
            if (audio_is_playing(Thirst___watson)) {
                audio_stop_sound(Thirst___watson);
            }
            if (audio_is_playing(Viento_del_sol___watson)) {
                audio_stop_sound(Viento_del_sol___watson);
            }
            
            room_goto(menu_room);
        } else if (selected_button == 3) {
            audio_sound_gain(sfx_confirm, 0.6, 0);
            audio_play_sound(sfx_confirm, 1, false);
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
            // Slice the lemon, then resume when it finishes
            selected_button = 0;
            slice_active = true;
            slice_kind = 0;
            slice_timer = 0;
            audio_sound_gain(sfx_slicing, 0.9, 0);
            slice_snd = audio_play_sound(sfx_slicing, 5, false);
            audio_sound_pitch(slice_snd, 1.8);
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
            // Slice the tomato, then restart when it finishes
            selected_button = 1;
            slice_active = true;
            slice_kind = 1;
            slice_timer = 0;
            audio_sound_gain(sfx_slicing, 0.9, 0);
            slice_snd = audio_play_sound(sfx_slicing, 5, false);
            audio_sound_pitch(slice_snd, 1.8);
        }
    } else {
        button_hover = -1;
    }
    
    // Play hover sound if mouse hover changed
    if (button_hover != previous_hover && button_hover != -1) {
        audio_play_sound(sfx_hover, 1, false);
    }
    previous_hover = button_hover;
}