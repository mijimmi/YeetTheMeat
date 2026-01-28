// === CHECK FOR SKIP INPUT ===
// Only allow skipping during first part of cutscene (not during dialogue)
if (cutscene_state != "done" && cutscene_state != "fade_out" && 
    cutscene_state != "dialogue_transition" && cutscene_state != "dialogue_show") {
    
    var skip_pressed = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_escape);
    
    // Gamepad input
    if (gamepad != -1 && gamepad_is_connected(gamepad)) {
        skip_pressed = skip_pressed || gamepad_button_check_pressed(gamepad, gp_start);
    }
    
    if (skip_pressed) {
        cutscene_state = "fade_out";
        state_timer = 0;
    }
}

// === BACKGROUND STAYS BLACK ===
// bg_alpha stays at 1 (full black) until fade_out

// === SKIP PROMPT PULSE ===
skip_pulse_timer += 0.05;

// === STATE MACHINE ===
state_timer++;

switch (cutscene_state) {
    case "left_enter":
        // Smooth movement from left
        left_x = lerp(left_x, left_target_x, move_speed);
        
        // Start dialogue early while left is still moving in
        if (state_timer > 30 && !dialogue_started) {
            dialogue_started = true;
            full_text = dialogue_lines[0];
            displayed_text = "";
            char_index = 0;
        }
        
        // Type out first dialogue while animating
        if (dialogue_started && current_line == 0) {
            type_timer++;
            if (type_timer >= type_speed && char_index < string_length(full_text)) {
                type_timer = 0;
                char_index++;
                displayed_text = string_copy(full_text, 1, char_index);
            }
        }
        
        // When close enough, start next character
        if (abs(left_x - left_target_x) < 50) {
            cutscene_state = "middle_enter";
            state_timer = 0;
            middle_alpha = 1;
        }
        break;
        
    case "middle_enter":
        // Keep left character at position
        left_x = lerp(left_x, left_target_x, move_speed);
        
        // Smooth movement from bottom
        middle_y = lerp(middle_y, middle_target_y, move_speed);
        
        // Continue typing first dialogue
        if (current_line == 0) {
            type_timer++;
            if (type_timer >= type_speed && char_index < string_length(full_text)) {
                type_timer = 0;
                char_index++;
                displayed_text = string_copy(full_text, 1, char_index);
            }
            // Check if first line done, move to second
            if (char_index >= string_length(full_text) && state_timer > 60) {
                current_line = 1;
                full_text = dialogue_lines[1];
                displayed_text = "";
                char_index = 0;
                state_timer = 0;
            }
        } else {
            // Type second dialogue
            type_timer++;
            if (type_timer >= type_speed && char_index < string_length(full_text)) {
                type_timer = 0;
                char_index++;
                displayed_text = string_copy(full_text, 1, char_index);
            }
        }
        
        // When close enough, start next character
        if (abs(middle_y - middle_target_y) < 50) {
            cutscene_state = "right_enter";
            state_timer = 0;
            right_alpha = 1;
        }
        break;
        
    case "right_enter":
        // Keep previous characters at position
        left_x = lerp(left_x, left_target_x, move_speed);
        middle_y = lerp(middle_y, middle_target_y, move_speed);
        
        // Smooth movement from right
        right_x = lerp(right_x, right_target_x, move_speed);
        
        // Continue typing dialogue
        if (current_line == 0) {
            type_timer++;
            if (type_timer >= type_speed && char_index < string_length(full_text)) {
                type_timer = 0;
                char_index++;
                displayed_text = string_copy(full_text, 1, char_index);
            }
            if (char_index >= string_length(full_text) && state_timer > 60) {
                current_line = 1;
                full_text = dialogue_lines[1];
                displayed_text = "";
                char_index = 0;
                state_timer = 0;
            }
        } else {
            type_timer++;
            if (type_timer >= type_speed && char_index < string_length(full_text)) {
                type_timer = 0;
                char_index++;
                displayed_text = string_copy(full_text, 1, char_index);
            }
        }
        
        // When close enough, go to waiting state
        if (abs(right_x - right_target_x) < 50) {
            cutscene_state = "dialogue_wait";
            state_timer = 0;
        }
        break;
    
    case "dialogue_wait":
        // Keep characters at final positions
        left_x = lerp(left_x, left_target_x, move_speed);
        middle_y = lerp(middle_y, middle_target_y, move_speed);
        right_x = lerp(right_x, right_target_x, move_speed);
        
        // Continue typing if not done
        if (current_line == 0) {
            type_timer++;
            if (type_timer >= type_speed && char_index < string_length(full_text)) {
                type_timer = 0;
                char_index++;
                displayed_text = string_copy(full_text, 1, char_index);
            }
            if (char_index >= string_length(full_text) && state_timer > 60) {
                current_line = 1;
                full_text = dialogue_lines[1];
                displayed_text = "";
                char_index = 0;
                state_timer = 0;
            }
        } else {
            type_timer++;
            if (type_timer >= type_speed && char_index < string_length(full_text)) {
                type_timer = 0;
                char_index++;
                displayed_text = string_copy(full_text, 1, char_index);
            }
            // After second line done, transition to silhouette
            if (char_index >= string_length(full_text) && state_timer > 90) {
                cutscene_state = "silhouette_show";
                state_timer = 0;
            }
        }
        break;
    
    case "silhouette_show":
        // Fade out previous sprites
        left_alpha = max(left_alpha - 0.05, 0);
        middle_alpha = max(middle_alpha - 0.05, 0);
        right_alpha = max(right_alpha - 0.05, 0);
        
        // Clear the displayed text from first scene
        displayed_text = "";
        
        // Fade in silhouette
        silhouette_alpha = min(silhouette_alpha + 0.08, 1);
        
        // After 1 second (60 frames), transition to hunger
        if (state_timer > 60) {
            cutscene_state = "hunger_show";
            state_timer = 0;
        }
        break;
    
    case "hunger_show":
        // Fade out silhouette
        silhouette_alpha = max(silhouette_alpha - 0.08, 0);
        
        // Fade in hunger
        hunger_alpha = min(hunger_alpha + 0.08, 1);
        
        // Shake effect
        if (hunger_alpha > 0.5) {
            hunger_shake_x = random_range(-hunger_shake_intensity, hunger_shake_intensity);
            hunger_shake_y = random_range(-hunger_shake_intensity, hunger_shake_intensity);
        }
        
        // After hunger is fully shown, wait then transition to dialogue (shorter duration)
        if (hunger_alpha >= 1 && state_timer > 60) {
            cutscene_state = "dialogue_transition";
            state_timer = 0;
        }
        break;
    
    case "dialogue_transition":
        // Keep hunger visible (don't fade out)
        // hunger_alpha stays at 1
        
        // Fade in dialogue background
        dialogue_bg_alpha = min(dialogue_bg_alpha + 0.05, 1);
        
        // When ready, start dialogue
        if (dialogue_bg_alpha >= 1) {
            cutscene_state = "dialogue_show";
            state_timer = 0;
            dialogue_index = 0;
            current_speaker = dialogue_lines_full[dialogue_index][0];
            dialogue_text_full = dialogue_lines_full[dialogue_index][1];
            dialogue_text_display = "";
            dialogue_char_index = 0;
            dialogue_text_complete = false;
        }
        break;
    
    case "dialogue_show":
        // Bob animation
        istar_bob += bob_speed;
        culay_bob += bob_speed;
        
        // Typewriter effect
        if (!dialogue_text_complete) {
            dialogue_type_timer++;
            if (dialogue_type_timer >= dialogue_type_speed && dialogue_char_index < string_length(dialogue_text_full)) {
                dialogue_type_timer = 0;
                dialogue_char_index++;
                dialogue_text_display = string_copy(dialogue_text_full, 1, dialogue_char_index);
            }
            if (dialogue_char_index >= string_length(dialogue_text_full)) {
                dialogue_text_complete = true;
            }
        }
        
        // Check for input to advance dialogue (NOT "A" key, that's for gamepad only)
        var advance_pressed = keyboard_check_pressed(vk_enter) || 
                             keyboard_check_pressed(vk_space);
        
        if (gamepad != -1 && gamepad_is_connected(gamepad)) {
            advance_pressed = advance_pressed || gamepad_button_check_pressed(gamepad, gp_face1);
        }
        
        if (advance_pressed && state_timer > 10) {
            // If text not complete, complete it instantly
            if (!dialogue_text_complete) {
                dialogue_text_display = dialogue_text_full;
                dialogue_char_index = string_length(dialogue_text_full);
                dialogue_text_complete = true;
            } else {
                // Text complete, advance to next line
                dialogue_index++;
                
                // Check if more dialogue left
                if (dialogue_index < array_length(dialogue_lines_full)) {
                    current_speaker = dialogue_lines_full[dialogue_index][0];
                    dialogue_text_full = dialogue_lines_full[dialogue_index][1];
                    dialogue_text_display = "";
                    dialogue_char_index = 0;
                    dialogue_text_complete = false;
                    state_timer = 0;
                } else {
                    // Dialogue finished, transition to soyjack scene
                    cutscene_state = "soyjack_transition";
                    state_timer = 0;
                }
            }
        }
        break;
    
    case "soyjack_transition":
        // Fade out all previous elements
        dialogue_bg_alpha = max(dialogue_bg_alpha - 0.05, 0);
        hunger_alpha = max(hunger_alpha - 0.05, 0);
        silhouette_alpha = max(silhouette_alpha - 0.05, 0);
        left_alpha = max(left_alpha - 0.05, 0);
        middle_alpha = max(middle_alpha - 0.05, 0);
        right_alpha = max(right_alpha - 0.05, 0);
        
        // Fade in soyjack background
        soyjack_bg_alpha = min(soyjack_bg_alpha + 0.05, 1);
        
        // When all previous elements are gone and background is ready, start soyjack animation
        if (soyjack_bg_alpha >= 1 && dialogue_bg_alpha <= 0 && hunger_alpha <= 0) {
            cutscene_state = "soyjack_show";
            state_timer = 0;
            soyjack_alpha = 1;
        }
        break;
    
    case "soyjack_show":
        // Move soyjack up from bottom
        soyjack_y = lerp(soyjack_y, soyjack_target_y, 0.04);
        
        // Shake effect once it's mostly in view
        if (soyjack_y < center_y + 200) {
            soyjack_shake_x = random_range(-soyjack_shake_intensity, soyjack_shake_intensity);
            soyjack_shake_y = random_range(-soyjack_shake_intensity, soyjack_shake_intensity);
        }
        
        // After animation and display, transition to final dialogue
        if (abs(soyjack_y - soyjack_target_y) < 20 && state_timer > 120) {
            cutscene_state = "final_dialogue_transition";
            state_timer = 0;
        }
        break;
    
    case "final_dialogue_transition":
        // Fade out soyjack
        soyjack_alpha = max(soyjack_alpha - 0.05, 0);
        
        // Keep background (it's the same for final dialogue)
        final_dialogue_bg_alpha = soyjack_bg_alpha;
        
        // When soyjack is gone, start final dialogue
        if (soyjack_alpha <= 0) {
            cutscene_state = "final_dialogue_show";
            state_timer = 0;
            final_dialogue_index = 0;
            final_current_speaker = final_dialogue_lines[final_dialogue_index][0];
            final_dialogue_text_full = final_dialogue_lines[final_dialogue_index][1];
            final_dialogue_text_display = "";
            final_dialogue_char_index = 0;
            final_dialogue_text_complete = false;
        }
        break;
    
    case "final_dialogue_show":
        // Bob animation
        final_istar_bob += bob_speed;
        final_culay_bob += bob_speed;
        
        // Typewriter effect
        if (!final_dialogue_text_complete) {
            final_dialogue_type_timer++;
            if (final_dialogue_type_timer >= final_dialogue_type_speed && final_dialogue_char_index < string_length(final_dialogue_text_full)) {
                final_dialogue_type_timer = 0;
                final_dialogue_char_index++;
                final_dialogue_text_display = string_copy(final_dialogue_text_full, 1, final_dialogue_char_index);
            }
            if (final_dialogue_char_index >= string_length(final_dialogue_text_full)) {
                final_dialogue_text_complete = true;
            }
        }
        
        // Check for input to advance dialogue
        var advance_pressed = keyboard_check_pressed(vk_enter) || 
                             keyboard_check_pressed(vk_space);
        
        if (gamepad != -1 && gamepad_is_connected(gamepad)) {
            advance_pressed = advance_pressed || gamepad_button_check_pressed(gamepad, gp_face1);
        }
        
        if (advance_pressed && state_timer > 10) {
            // If text not complete, complete it instantly
            if (!final_dialogue_text_complete) {
                final_dialogue_text_display = final_dialogue_text_full;
                final_dialogue_char_index = string_length(final_dialogue_text_full);
                final_dialogue_text_complete = true;
            } else {
                // Text complete, advance to next line
                final_dialogue_index++;
                
                // Check if more dialogue left
                if (final_dialogue_index < array_length(final_dialogue_lines)) {
                    final_current_speaker = final_dialogue_lines[final_dialogue_index][0];
                    final_dialogue_text_full = final_dialogue_lines[final_dialogue_index][1];
                    final_dialogue_text_display = "";
                    final_dialogue_char_index = 0;
                    final_dialogue_text_complete = false;
                    state_timer = 0;
                } else {
                    // Dialogue finished, transition to final animation
                    cutscene_state = "final_animation_transition";
                    state_timer = 0;
                }
            }
        }
        break;
    
    case "final_animation_transition":
        // Fade out text (if any was showing)
        // Background stays (noorangebg)
        
        // Start animations immediately
        if (state_timer > 10) {
            cutscene_state = "final_animation";
            state_timer = 0;
            cheer_alpha = 1;
            servethepeople_alpha = 1;
        }
        break;
    
    case "final_animation":
        // Move cheer up from bottom
        cheer_y = lerp(cheer_y, cheer_target_y, 0.05);
        
        // Move serve the people down from top
        servethepeople_y = lerp(servethepeople_y, servethepeople_target_y, 0.05);
        
        // Once both are in position, show press key prompt
        if (abs(cheer_y - cheer_target_y) < 20 && abs(servethepeople_y - servethepeople_target_y) < 20) {
            press_key_alpha = min(press_key_alpha + 0.03, 1);
            
            // Check for any key press to start game
            if (press_key_alpha >= 1 && state_timer > 30) {
                var any_key = keyboard_check_pressed(vk_anykey) || 
                             mouse_check_button_pressed(mb_any);
                
                if (gamepad != -1 && gamepad_is_connected(gamepad)) {
                    any_key = any_key || gamepad_button_check_pressed(gamepad, gp_face1) ||
                             gamepad_button_check_pressed(gamepad, gp_start);
                }
                
                if (any_key) {
                    cutscene_state = "fade_out";
                    state_timer = 0;
                }
            }
        }
        break;
        
    case "fade_out":
        // Fade everything out
        fade_alpha = min(fade_alpha + 0.03, 1);
        dialogue_alpha = max(dialogue_alpha - 0.05, 0);
        
        // When fully faded, show loading screen
        if (fade_alpha >= 1 && state_timer > 30) {
            cutscene_state = "loading";
            state_timer = 0;
            loading_timer = 0;
            fade_alpha = 0;  // Reset fade for loading screen
        }
        break;
    
    case "loading":
        // Animate loading elements
        loading_timer++;
        loading_icon_bounce += 0.15;
        loading_icon_rotation += 2;
        
        // Update dot animation (3 dots cycling)
        if (loading_timer % 20 == 0) {
            loading_dot_count = (loading_dot_count + 1) % 4;
        }
        
        // After showing loading screen for a bit, end cutscene
        if (loading_timer > 90) {
            cutscene_state = "done";
            global.game_paused = false;
            instance_destroy();
        }
        break;
}
