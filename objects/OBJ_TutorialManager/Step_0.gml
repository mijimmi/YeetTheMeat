// Update instruction fade
instruction_alpha = lerp(instruction_alpha, target_alpha, 0.1);

// Update arrow bounce animation
arrow_bounce += 0.15;

// Gentle idle bob for the instruction card
box_bob_timer += 0.05;

// Controls screen animations
if (current_phase == "controls") {
    controls_anim_timer++;
}

// === TYPING ANIMATION ===
if (!instruction_text_complete && instruction_text_full != "") {
    instruction_type_timer++;
    if (instruction_type_timer >= instruction_type_speed && instruction_char_index < string_length(instruction_text_full)) {
        instruction_type_timer = 0;
        instruction_char_index++;
        instruction_text_display = string_copy(instruction_text_full, 1, instruction_char_index);
        
        // Play Istar's voice every 3 characters (low-pitched meow, matching cutscene)
        if (instruction_char_index % 3 == 0) {
            audio_stop_sound(sfx_meow_talk);
            audio_sound_gain(sfx_meow_talk, 0.3, 0);
            audio_sound_pitch(sfx_meow_talk, 0.6);
            audio_play_sound(sfx_meow_talk, 1, false);
        }
    }
    if (instruction_char_index >= string_length(instruction_text_full)) {
        instruction_text_complete = true;
        audio_stop_sound(sfx_meow_talk);
    }
}

// === CHECK FOR SKIP TUTORIAL (SELECT BUTTON) - Either player can skip ===
if (current_phase != "complete") { // Only allow skip if not already complete
    if (gamepad_button_check_pressed(0, gp_select) || gamepad_button_check_pressed(1, gp_select) || keyboard_check_pressed(vk_tab)) { // SELECT button from P1 or P2
        show_debug_message("Tutorial skipped!");
        
        // Stop tutorial music
        if (audio_is_playing(Under_the_Cobblestone_watson)) {
            audio_stop_sound(Under_the_Cobblestone_watson);
        }
        
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

    // === ANIMATE COMPLETE SCREEN ===
    // Card slides up from below
    complete_card_y_offset = lerp(complete_card_y_offset, complete_card_target_y, 0.12);
    // Headline pops in then gently pulses
    if (complete_headline_scale < 1.0) {
        complete_headline_scale = min(complete_headline_scale + 0.06, 1.0);
    }
    complete_headline_timer++;
    complete_star_timer++;
    complete_prompt_blink++;
    
    // Play complete sound once when entering this phase
    if (!variable_instance_exists(id, "complete_sound_played")) {
        complete_sound_played = false;
    }
    if (!complete_sound_played) {
        // Stop all in-game sounds (cooking, slicing, etc.) before playing complete jingle
        audio_stop_sound(sfx_cooking);
        audio_stop_sound(sfx_slicing);
        audio_stop_sound(sfx_saucing);
        // Kill any gamepad vibration
        gamepad_set_vibration(0, 0, 0);
        gamepad_set_vibration(1, 0, 0);

        audio_sound_gain(sfx_complete, 0.85, 0);
        audio_play_sound(sfx_complete, 1, false);
        complete_sound_played = true;
    }
    
    // === TYPE OUT COMPLETE SCREEN TEXT ===
    // "TUTORIAL COMPLETE!"
    if (!complete_text_complete) {
        complete_type_timer++;
        if (complete_type_timer >= complete_type_speed && complete_char_index < string_length(complete_text_full)) {
            complete_type_timer = 0;
            complete_char_index++;
            complete_text_display = string_copy(complete_text_full, 1, complete_char_index);
            
            if (complete_char_index % 2 == 0) {
                audio_stop_sound(sfx_text_talk);
                audio_sound_gain(sfx_text_talk, 0.8, 0);
                audio_play_sound(sfx_text_talk, 1, false);
            }
        }
        if (complete_char_index >= string_length(complete_text_full)) {
            complete_text_complete = true;
            audio_stop_sound(sfx_text_talk);
        }
    }
    // "Press -A- to start the game!"
    else if (!continue_text_complete) {
        continue_type_timer++;
        if (continue_type_timer >= continue_type_speed && continue_char_index < string_length(continue_text_full)) {
            continue_type_timer = 0;
            continue_char_index++;
            continue_text_display = string_copy(continue_text_full, 1, continue_char_index);
            
            if (continue_char_index % 2 == 0) {
                audio_stop_sound(sfx_text_talk);
                audio_sound_gain(sfx_text_talk, 0.8, 0);
                audio_play_sound(sfx_text_talk, 1, false);
            }
        }
        if (continue_char_index >= string_length(continue_text_full)) {
            continue_text_complete = true;
            audio_stop_sound(sfx_text_talk);
        }
    }
    // Recipe book reminder
    else if (!reminder_text_complete) {
        reminder_type_timer++;
        if (reminder_type_timer >= reminder_type_speed && reminder_char_index < string_length(reminder_text_full)) {
            reminder_type_timer = 0;
            reminder_char_index++;
            reminder_text_display = string_copy(reminder_text_full, 1, reminder_char_index);
            
            if (reminder_char_index % 3 == 0) {
                audio_stop_sound(sfx_text_talk);
                audio_sound_gain(sfx_text_talk, 0.8, 0);
                audio_play_sound(sfx_text_talk, 1, false);
            }
        }
        if (reminder_char_index >= string_length(reminder_text_full)) {
            reminder_text_complete = true;
            audio_stop_sound(sfx_text_talk);
        }
    }
    // Warning text
    else if (!warning_text_complete) {
        warning_type_timer++;
        if (warning_type_timer >= warning_type_speed && warning_char_index < string_length(warning_text_full)) {
            warning_type_timer = 0;
            warning_char_index++;
            warning_text_display = string_copy(warning_text_full, 1, warning_char_index);
            
            if (warning_char_index % 2 == 0) {
                audio_stop_sound(sfx_text_talk);
                audio_sound_gain(sfx_text_talk, 0.8, 0);
                audio_play_sound(sfx_text_talk, 1, false);
            }
        }
        if (warning_char_index >= string_length(warning_text_full)) {
            warning_text_complete = true;
            audio_stop_sound(sfx_text_talk);
        }
    }
    // Warning subtext
    else if (!warning_subtext_complete) {
        warning_subtext_type_timer++;
        if (warning_subtext_type_timer >= warning_subtext_type_speed && warning_subtext_char_index < string_length(warning_subtext_full)) {
            warning_subtext_type_timer = 0;
            warning_subtext_char_index++;
            warning_subtext_display = string_copy(warning_subtext_full, 1, warning_subtext_char_index);
            
            if (warning_subtext_char_index % 3 == 0) {
                audio_stop_sound(sfx_text_talk);
                audio_sound_gain(sfx_text_talk, 0.8, 0);
                audio_play_sound(sfx_text_talk, 1, false);
            }
        }
        if (warning_subtext_char_index >= string_length(warning_subtext_full)) {
            warning_subtext_complete = true;
            audio_stop_sound(sfx_text_talk);
        }
    }
    
    // Proceed once continue prompt has finished typing — any key / button
    if (continue_text_complete) {
        var proceed_pressed = keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_any);
        if (gamepad_is_connected(0)) {
            proceed_pressed = proceed_pressed ||
                gamepad_button_check_pressed(0, gp_face1) ||
                gamepad_button_check_pressed(0, gp_face3) ||
                gamepad_button_check_pressed(0, gp_start);
        }
        if (gamepad_is_connected(1)) {
            proceed_pressed = proceed_pressed ||
                gamepad_button_check_pressed(1, gp_face1) ||
                gamepad_button_check_pressed(1, gp_face3) ||
                gamepad_button_check_pressed(1, gp_start);
        }
        if (proceed_pressed) {
            // Stop tutorial music
            if (audio_is_playing(Under_the_Cobblestone_watson)) {
                audio_stop_sound(Under_the_Cobblestone_watson);
            }
            
            // Unpause and go to main game room
            global.game_paused = false;
            global.show_tutorial = false;
            room_goto(game_room);
        }
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
    controls_idle_timer++;

    // Require a short read before the player can continue. This also prevents
    // any input buffered from the movement phase from instantly skipping it.
    var can_continue = controls_anim_timer >= 90; // ~1.5s minimum on screen

    if (can_continue && alarm[0] < 0) {
        var pressed_continue =
            gamepad_button_check_pressed(0, global.btn_action) || gamepad_button_check_pressed(1, global.btn_action) ||
            gamepad_button_check_pressed(0, gp_face1)          || gamepad_button_check_pressed(1, gp_face1) ||
            keyboard_check_pressed(ord("E"))                   || keyboard_check_pressed(ord("U")) ||
            keyboard_check_pressed(vk_space)                   || keyboard_check_pressed(vk_enter);

        if (pressed_continue) {
            alarm[0] = 1; // proceed to the recipe phase
        }
    }

    // Failsafe so the player can never soft-lock here (long, unobtrusive).
    if (controls_idle_timer >= 1200 && alarm[0] < 0) { // ~20 seconds
        alarm[0] = 1;
    }
}

// === RECIPE PHASE ===
else if (current_phase == "recipe") {
    // During steps 2-5 the wrapper must stay in the mixer. If a player
    // accidentally picks it up while empty-handed, silently respawn it so
    // the tutorial doesn't soft-lock.
    if (tutorial_step >= 2 && tutorial_step <= 5) {
        var _mixer = instance_find(OBJ_MixingStation, 0);
        if (instance_exists(_mixer) && _mixer.ingredient1 == noone && _mixer.food_on_station == noone) {
            var _w = instance_create_depth(
                _mixer.x + _mixer.food_offset_x - 15,
                _mixer.y + _mixer.food_offset_y,
                _mixer.depth - 1,
                OBJ_LumpiaWrapper
            );
            _w.can_slide = false;
            _w.velocity_x = 0;
            _w.velocity_y = 0;
            _mixer.ingredient1 = _w;
        }
    }
    check_recipe_tutorial();
}

// === SERVE PHASE ===
else if (current_phase == "serve") {
    check_serve_tutorial();
}