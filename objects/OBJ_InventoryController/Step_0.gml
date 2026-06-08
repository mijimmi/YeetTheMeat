// Inventory Controller Step Event
// (Timer moved to OBJ_TimerController)

recipe_sel_pulse += 1;

// === RECIPE BOOK ANIMATION ===
if (recipe_opening) {
    recipe_anim_progress += recipe_anim_speed;
    if (recipe_anim_progress >= 1) {
        recipe_anim_progress = 1;
        recipe_opening = false;
    }
}
else if (recipe_closing) {
    recipe_anim_progress -= recipe_anim_speed;
    if (recipe_anim_progress <= 0) {
        recipe_anim_progress = 0;
        recipe_closing = false;
        recipe_book_open = false;
        global.game_paused = false;

        // Book fully closed: start the dish tutorial if one is highlighted
        // (not during the scripted onboarding tutorial). The selection is kept
        // so reopening the book lands on the highlighted dish where the player
        // can unhighlight it to cancel; it's cleared automatically once the
        // guide is fully completed (see OBJ_HintController Step).
        if (recipe_selected_dish != "" && !instance_exists(OBJ_TutorialManager)) {
            with (OBJ_HintController) {
                start_dish_guide(other.recipe_selected_dish);
            }
        }
    }
}

// === RECIPE BOOK TOGGLE (SELECT button) ===
var select_pressed = false;

// Check gamepad SELECT
if (gamepad_is_connected(0)) {
    if (gamepad_button_check_pressed(0, gp_select)) {
        select_pressed = true;
    }
}
if (gamepad_is_connected(1)) {
    if (gamepad_button_check_pressed(1, gp_select)) {
        select_pressed = true;
    }
}

// Check keyboard (Tab key as alternative)
if (keyboard_check_pressed(vk_tab)) {
    select_pressed = true;
}

// Toggle recipe book (can open when not paused, can always close when open)
if (select_pressed && !recipe_opening && !recipe_closing) {
    if (recipe_book_open) {
        // Start closing animation
        recipe_closing = true;
        
        // Play recipe close sound
        audio_sound_gain(sfx_recipeopen, 0.5, 0);
        audio_play_sound(sfx_recipeopen, 1, false);
    }
    else if (!global.game_paused) {
        // Start opening animation
        recipe_book_open = true;
        recipe_opening = true;
        recipe_hint_dismissed = true;  // dismiss the "learn how to cook" prompt
        // Land on the highlighted dish (page + side) so the player can instantly
        // unhighlight/cancel it, even when it's the right-hand dish. Falls back to
        // the last viewed page / left side when nothing is highlighted.
        recipe_cursor_side = 0;
        if (recipe_selected_dish != "") {
            for (var _pg = 1; _pg <= recipe_total_pages; _pg++) {
                if (recipe_dish_at(_pg, 0) == recipe_selected_dish) {
                    recipe_current_page = _pg; recipe_cursor_side = 0; break;
                }
                if (recipe_dish_at(_pg, 1) == recipe_selected_dish) {
                    recipe_current_page = _pg; recipe_cursor_side = 1; break;
                }
            }
        }
        global.game_paused = true;

        // Opening the book cancels any running dish tutorial so the player
        // can re-choose (or unhighlight) before closing again.
        if (instance_exists(OBJ_HintController)) {
            with (OBJ_HintController) { cancel_dish_guide(); }
        }
        
        // Play recipe open sound
        audio_sound_gain(sfx_recipeopen, 0.5, 0);
        audio_play_sound(sfx_recipeopen, 1, false);
    }
}

// === RECIPE PAGE NAVIGATION (LT/RT or Q/E) ===
if (recipe_book_open && !recipe_opening && !recipe_closing) {
    var prev_page = false;
    var next_page = false;
    
    // Check gamepad LT/RT (shoulders)
    if (gamepad_is_connected(0)) {
        if (gamepad_button_check_pressed(0, gp_shoulderlb)) prev_page = true;
        if (gamepad_button_check_pressed(0, gp_shoulderrb)) next_page = true;
    }
    if (gamepad_is_connected(1)) {
        if (gamepad_button_check_pressed(1, gp_shoulderlb)) prev_page = true;
        if (gamepad_button_check_pressed(1, gp_shoulderrb)) next_page = true;
    }
    
    // Check keyboard Q/E
    if (keyboard_check_pressed(ord("Q"))) prev_page = true;
    if (keyboard_check_pressed(ord("E"))) next_page = true;
    
    // Navigate pages
    if (prev_page && recipe_current_page > 1) {
        recipe_current_page--;
        
        // Play page turn sound
        audio_sound_gain(sfx_pageturn, 0.5, 0);
        audio_play_sound(sfx_pageturn, 1, false);
    }
    if (next_page && recipe_current_page < recipe_total_pages) {
        recipe_current_page++;
        
        // Play page turn sound
        audio_sound_gain(sfx_pageturn, 0.5, 0);
        audio_play_sound(sfx_pageturn, 1, false);
    }
}

// === RECIPE DISH SELECTION (choose left/right dish, confirm with action button) ===
if (recipe_book_open && !recipe_opening && !recipe_closing) {
    // --- Move the focus between the left and right dish ---
    var move_left = false;
    var move_right = false;

    if (gamepad_is_connected(0)) {
        if (gamepad_button_check_pressed(0, gp_padl) || gamepad_axis_value(0, gp_axislh) < -0.5) move_left = true;
        if (gamepad_button_check_pressed(0, gp_padr) || gamepad_axis_value(0, gp_axislh) >  0.5) move_right = true;
    }
    if (gamepad_is_connected(1)) {
        if (gamepad_button_check_pressed(1, gp_padl) || gamepad_axis_value(1, gp_axislh) < -0.5) move_left = true;
        if (gamepad_button_check_pressed(1, gp_padr) || gamepad_axis_value(1, gp_axislh) >  0.5) move_right = true;
    }
    if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"))) move_left = true;
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) move_right = true;

    // Use an analog-stick debounce so the focus doesn't fly across instantly
    if (!variable_instance_exists(id, "recipe_stick_locked")) recipe_stick_locked = false;
    var stick_held = false;
    if (gamepad_is_connected(0) && abs(gamepad_axis_value(0, gp_axislh)) > 0.5) stick_held = true;
    if (gamepad_is_connected(1) && abs(gamepad_axis_value(1, gp_axislh)) > 0.5) stick_held = true;
    if (!stick_held) recipe_stick_locked = false;
    if (recipe_stick_locked) { move_left = false; move_right = false; }

    var new_side = recipe_cursor_side;
    if (move_left)  new_side = 0;
    if (move_right) new_side = 1;

    // Don't allow focusing a side that has no selectable dish (e.g. drinks page)
    if (new_side != recipe_cursor_side && recipe_dish_at(recipe_current_page, new_side) != "") {
        recipe_cursor_side = new_side;
        if (stick_held) recipe_stick_locked = true;
        audio_sound_gain(sfx_hover, 0.5, 0);
        audio_play_sound(sfx_hover, 1, false);
    }

    // Keep the focus on a valid side when the page changes
    if (recipe_dish_at(recipe_current_page, recipe_cursor_side) == "") {
        recipe_cursor_side = 0;
    }

    // --- Confirm / unhighlight the focused dish ---
    var confirm = false;
    if (gamepad_is_connected(0)) {
        if (gamepad_button_check_pressed(0, gp_face1) || gamepad_button_check_pressed(0, gp_face3)) confirm = true;
    }
    if (gamepad_is_connected(1)) {
        if (gamepad_button_check_pressed(1, gp_face1) || gamepad_button_check_pressed(1, gp_face3)) confirm = true;
    }
    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) confirm = true;

    if (confirm) {
        var focused = recipe_dish_at(recipe_current_page, recipe_cursor_side);
        if (focused != "") {
            if (recipe_selected_dish == focused) {
                // Pressing again unhighlights it
                recipe_selected_dish = "";
                audio_sound_gain(sfx_pause, 0.5, 0);
                audio_play_sound(sfx_pause, 1, false);
            } else {
                recipe_selected_dish = focused;
                audio_sound_gain(sfx_confirm, 0.6, 0);
                audio_play_sound(sfx_confirm, 1, false);
            }
        }
    }
}
