// Create Event
paused = false;
pause_surf = -1; // Surface to store game screenshot

// Button properties
button_width = 300;
button_height = 80;
button_spacing = 20;

// Button positions (relative to center)
resume_y_offset = 40;
restart_y_offset = 120;

selected_button = 0; // 0 = resume, 1 = restart, 2 = menu, 3 = exit
button_hover = -1; // -1 = none, 0 = resume, 1 = restart

// Track previous selection for hover sound
previous_selected = selected_button;
previous_hover = button_hover;

// Navigation cooldown to prevent rapid switching
nav_cooldown = 0;
nav_cooldown_max = 10; // frames between navigation

// Pause animation (slide up/down)
pause_anim_y = 300;  // Current Y offset (starts off-screen below)
pause_anim_target = 0; // Target Y offset (0 = centered)
pause_anim_speed = 0.12; // How fast to lerp
pause_anim_alpha = 0; // Fade in alpha
unpausing = false; // Track if we're in unpause animation

// Staggered entrance + ongoing menu animation
pause_timer = 0;          // frames since the menu opened (drives entrance stagger)
play_icon_scale = 1;      // smoothed scale for the play (resume) icon
restart_icon_scale = 1;   // smoothed scale for the restart icon

// Confirm "slice" animation: choosing RESUME slices the lemon, RESTART slices
// the tomato. A blade sweeps across the screen, the chosen icon splits into two
// halves that slide apart and drop, then the real action fires when it ends.
slice_active = false;
slice_kind = -1;          // 0 = resume (lemon), 1 = restart (tomato)
slice_timer = 0;
slice_duration = 40;      // frames for the whole slice before the action triggers
slice_snd = -1;           // playing slice sfx id (so we can cut it short)

// Draws a full-screen icon sprite cut down the middle into two falling halves.
// Uses draw_sprite_part_ext so (x,y) is an exact top-left anchor (no origin
// ambiguity), which keeps the two halves aligned with the original icon.
draw_sliced_icon = function(spr, xs, ys, split, fall, alpha) {
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    var sw2 = sprite_get_width(spr);
    var sh2 = sprite_get_height(spr);
    var halfw = floor(sw2 / 2);
    var tlx = gw / 2 - (sw2 * xs) / 2;
    var tly = gh / 2 - (sh2 * ys) / 2;
    // Left half slides left + drops
    draw_sprite_part_ext(spr, 0, 0, 0, halfw, sh2,
        tlx - split, tly + fall, xs, ys, c_white, alpha);
    // Right half slides right + drops
    draw_sprite_part_ext(spr, 0, halfw, 0, sw2 - halfw, sh2,
        tlx + halfw * xs + split, tly + fall, xs, ys, c_white, alpha);
};