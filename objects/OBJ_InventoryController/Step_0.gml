// Inventory Controller Step Event
// (Timer moved to OBJ_TimerController)

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
    }
    else if (!global.game_paused) {
        // Start opening animation
        recipe_book_open = true;
        recipe_opening = true;
        recipe_current_page = 1;  // Reset to first page
        global.game_paused = true;
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
    }
    if (next_page && recipe_current_page < recipe_total_pages) {
        recipe_current_page++;
    }
}
