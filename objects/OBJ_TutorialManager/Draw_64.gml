if (instruction_alpha > 0.01 && current_phase != "complete") {
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var text_scale = 2.5; // Big, readable text
    var text_w = string_width(instruction_text_full) * text_scale; // Full text for stable box size
    var text_h = string_height(instruction_text_full) * text_scale;

    // Position between middle and bottom of screen
    var gui_h = display_get_gui_height();
    var center_y = gui_h / 2;
    var bottom_y = gui_h;
    var base_y = (center_y + bottom_y) / 2;

    // Gentle idle bob so the card feels alive
    var bob = sin(box_bob_timer) * 4;
    var card_cy = base_y + bob;

    // Card bounds
    var pad = box_padding;
    var box_x1 = instruction_x - (text_w / 2) - pad;
    var box_y1 = card_cy - (text_h / 2) - pad;
    var box_x2 = instruction_x + (text_w / 2) + pad;
    var box_y2 = card_cy + (text_h / 2) + pad;
    var rad = 26; // Rounded corners

    // --- Soft drop shadow ---
    draw_set_alpha(0.22 * instruction_alpha);
    draw_set_color(c_black);
    draw_roundrect_ext(box_x1 + 8, box_y1 + 10, box_x2 + 8, box_y2 + 10, rad, rad, false);

    // --- Cream card fill ---
    draw_set_alpha(box_alpha * instruction_alpha);
    draw_set_color(box_color);
    draw_roundrect_ext(box_x1, box_y1, box_x2, box_y2, rad, rad, false);

    // --- Hand-drawn double border (brown) ---
    draw_set_alpha(instruction_alpha);
    draw_set_color(highlight_color);
    draw_roundrect_ext(box_x1, box_y1, box_x2, box_y2, rad, rad, true);
    draw_roundrect_ext(box_x1 + 4, box_y1 + 4, box_x2 - 4, box_y2 - 4, rad - 4, rad - 4, true);

    // --- "TUTORIAL" tab pill above the card ---
    var tab_text = "TUTORIAL";
    var tab_scale = 1.6;
    var tab_w = string_width(tab_text) * tab_scale;
    var tab_h = string_height(tab_text) * tab_scale;
    var tab_cx = instruction_x;
    var tab_cy = box_y1 - tab_h * 0.5 - 6;
    var tab_x1 = tab_cx - tab_w / 2 - 22;
    var tab_x2 = tab_cx + tab_w / 2 + 22;
    var tab_y1 = tab_cy - tab_h / 2 - 8;
    var tab_y2 = tab_cy + tab_h / 2 + 8;

    // Tab fill (brown) + cream outline
    draw_set_color(highlight_color);
    draw_roundrect_ext(tab_x1, tab_y1, tab_x2, tab_y2, 18, 18, false);
    draw_set_color(box_color);
    draw_roundrect_ext(tab_x1, tab_y1, tab_x2, tab_y2, 18, 18, true);
    // Tab label (cream)
    draw_set_color(box_color);
    draw_text_transformed(tab_cx, tab_cy, tab_text, tab_scale, tab_scale, 0);

    // --- Instruction text (brown ink, typing effect) ---
    draw_set_color(text_color);
    draw_text_transformed(instruction_x, card_cy, instruction_text_display, text_scale, text_scale, 0);

    // --- Skip hint chip below the card ---
    var skip_text = "Stuck? Press " + tut_select_key() + " to skip";
    var skip_scale = 1.3;
    var skip_y = box_y2 + 34;
    draw_set_valign(fa_top);
    // outline
    draw_set_color(c_black);
    for (var sx = -2; sx <= 2; sx += 2) {
        for (var sy = -2; sy <= 2; sy += 2) {
            if (sx != 0 || sy != 0) {
                draw_text_transformed(instruction_x + sx, skip_y + sy, skip_text, skip_scale, skip_scale, 0);
            }
        }
    }
    draw_set_color(make_color_rgb(255, 240, 200));
    draw_text_transformed(instruction_x, skip_y, skip_text, skip_scale, skip_scale, 0);

    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// TUTORIAL COMPLETE SCREEN
if (current_phase == "complete") {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var cx = gui_w / 2;
    var cy = gui_h / 2 + complete_card_y_offset; // Slides in from below

    // Warm dark overlay
    draw_set_alpha(0.82);
    draw_set_color(make_color_rgb(40, 28, 20));
    draw_rectangle(0, 0, gui_w, gui_h, false);
    draw_set_alpha(1);

    // === Big cream card (slides in) ===
    var cc_w = 860;
    var cc_h = 460;
    var cc_x1 = cx - cc_w / 2;
    var cc_x2 = cx + cc_w / 2;
    var cc_y1 = cy - cc_h / 2;
    var cc_y2 = cy + cc_h / 2;
    var cc_rad = 34;

    // Drop shadow
    draw_set_alpha(0.28);
    draw_set_color(c_black);
    draw_roundrect_ext(cc_x1 + 12, cc_y1 + 14, cc_x2 + 12, cc_y2 + 14, cc_rad, cc_rad, false);
    // Cream fill
    draw_set_alpha(0.98);
    draw_set_color(box_color);
    draw_roundrect_ext(cc_x1, cc_y1, cc_x2, cc_y2, cc_rad, cc_rad, false);
    // Brown double border
    draw_set_alpha(1);
    draw_set_color(highlight_color);
    draw_roundrect_ext(cc_x1, cc_y1, cc_x2, cc_y2, cc_rad, cc_rad, true);
    draw_roundrect_ext(cc_x1 + 5, cc_y1 + 5, cc_x2 - 5, cc_y2 - 5, cc_rad - 4, cc_rad - 4, true);

    // === TUTORIAL COMPLETE pill badge at top ===
    var pill_text = "TUTORIAL COMPLETE";
    var pill_s = 1.4;
    var pill_tw = string_width(pill_text) * pill_s;
    var pill_th = string_height(pill_text) * pill_s;
    var pill_cy = cc_y1 + 46;
    var pill_x1 = cx - pill_tw / 2 - 28;
    var pill_x2 = cx + pill_tw / 2 + 28;
    var pill_y1 = pill_cy - pill_th / 2 - 10;
    var pill_y2 = pill_cy + pill_th / 2 + 10;

    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(highlight_color);
    draw_roundrect_ext(pill_x1, pill_y1, pill_x2, pill_y2, 20, 20, false);
    draw_set_color(box_color);
    draw_roundrect_ext(pill_x1, pill_y1, pill_x2, pill_y2, 20, 20, true);
    draw_set_color(box_color);
    draw_text_transformed(cx, pill_cy, pill_text, pill_s, pill_s, 0);

    // === Decorative divider ===
    var divider_y = pill_y2 + 16;
    draw_set_color(highlight_color);
    draw_set_alpha(0.45);
    draw_line_width(cc_x1 + 50, divider_y, cc_x2 - 50, divider_y, 2);
    draw_set_alpha(1);

    // === Animated sparkle stars around headline ===
    var star_positions = [
        [cc_x1 + 55, cc_y1 + 48],
        [cc_x2 - 55, cc_y1 + 48],
        [cc_x1 + 100, cc_y1 + 100],
        [cc_x2 - 100, cc_y1 + 100],
    ];
    var star_color = make_color_rgb(220, 170, 60);
    for (var si = 0; si < 4; si++) {
        var sx = star_positions[si][0];
        var sy = star_positions[si][1];
        var star_phase = complete_star_timer * 0.07 + si * 1.4;
        var star_s = 0.7 + sin(star_phase) * 0.3;
        var star_rot = complete_star_timer * 1.5 + si * 45;
        var star_alpha = 0.5 + sin(star_phase + 1.0) * 0.4;
        draw_set_alpha(star_alpha);
        draw_set_color(star_color);
        // Draw a simple 4-point star as two crossed lines
        var arm = 10 * star_s;
        var arm2 = arm * 0.5;
        var rcos = dcos(star_rot);
        var rsin = dsin(star_rot);
        draw_line_width(sx - arm * rcos, sy + arm * rsin, sx + arm * rcos, sy - arm * rsin, 3);
        draw_line_width(sx - arm * (-rsin), sy + arm * rcos, sx + arm * (-rsin), sy - arm * rcos, 3);
        draw_line_width(sx - arm2 * dcos(star_rot + 45), sy + arm2 * dsin(star_rot + 45),
                        sx + arm2 * dcos(star_rot + 45), sy - arm2 * dsin(star_rot + 45), 2);
        draw_line_width(sx - arm2 * dcos(star_rot + 135), sy + arm2 * dsin(star_rot + 135),
                        sx + arm2 * dcos(star_rot + 135), sy - arm2 * dsin(star_rot + 135), 2);
    }
    draw_set_alpha(1);

    // === Main headline — white, pops in, gentle pulse ===
    var headline_y = divider_y + 68;
    var pulse = 1.0 + sin(complete_headline_timer * 0.055) * 0.025;
    var hs = complete_headline_scale * 2.6 * pulse;
    // Warm outline
    draw_set_color(make_color_rgb(160, 100, 30));
    for (var ox = -4; ox <= 4; ox += 4) {
        for (var oy = -4; oy <= 4; oy += 4) {
            if (ox != 0 || oy != 0) {
                draw_text_transformed(cx + ox, headline_y + oy, complete_text_display, hs, hs, 0);
            }
        }
    }
    draw_set_color(c_white);
    draw_text_transformed(cx, headline_y, complete_text_display, hs, hs, 0);

    // === Continue prompt — blinks gently once typing is done ===
    var continue_y = headline_y + 80;
    var prompt_alpha = continue_text_complete ? (0.7 + sin(complete_prompt_blink * 0.08) * 0.3) : 1.0;
    draw_set_alpha(prompt_alpha);
    draw_set_color(text_color);
    draw_text_transformed(cx, continue_y, continue_text_display, 1.85, 1.85, 0);
    draw_set_alpha(1);

    // === Tip line ===
    var tip_y = continue_y + 52;
    draw_set_color(make_color_rgb(140, 100, 60));
    draw_text_transformed(cx, tip_y, reminder_text_display, 1.3, 1.3, 0);

    // === Warning chip at the bottom of the card ===
    var warn_y = cc_y2 - 62;
    if (string_length(warning_text_display) > 0) {
        var wt_w = string_width(warning_text_display) * 1.4 + 40;
        var wt_h = string_height(warning_text_display) * 1.4 + 18;
        var wt_x1 = cx - wt_w / 2;
        var wt_x2 = cx + wt_w / 2;
        var wt_y1 = warn_y - wt_h / 2;
        var wt_y2 = warn_y + wt_h / 2;
        draw_set_alpha(0.15);
        draw_set_color(make_color_rgb(190, 70, 50));
        draw_roundrect_ext(wt_x1, wt_y1, wt_x2, wt_y2, 14, 14, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(190, 70, 50));
        draw_roundrect_ext(wt_x1, wt_y1, wt_x2, wt_y2, 14, 14, true);
    }
    draw_set_color(make_color_rgb(190, 70, 50));
    draw_text_transformed(cx, warn_y, warning_text_display, 1.4, 1.4, 0);

    var warn_sub_y = warn_y + 30;
    draw_set_color(make_color_rgb(140, 80, 60));
    draw_text_transformed(cx, warn_sub_y, warning_subtext_display, 1.2, 1.2, 0);

    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// === NOW PLAYING (Top Right Corner - Shows always) ===
draw_set_font(global.game_font);
draw_set_halign(fa_right);
draw_set_valign(fa_top);

var gui_w = display_get_gui_width();
var now_playing_x = gui_w - 30; // 30px from right edge
var now_playing_y = 30; // 30px from top
var text_scale = 1.2;
var line_spacing = 25;

// "Now Playing" label
draw_set_color(c_black);
draw_text_transformed(now_playing_x + 1, now_playing_y + 1, "Now Playing:", text_scale, text_scale, 0);
draw_set_color(make_color_rgb(255, 200, 100)); // Light orange/yellow
draw_text_transformed(now_playing_x, now_playing_y, "Now Playing:", text_scale, text_scale, 0);

// Song title
draw_set_color(c_black);
draw_text_transformed(now_playing_x + 1, now_playing_y + line_spacing + 1, song_title, text_scale * 0.9, text_scale * 0.9, 0);
draw_set_color(c_white);
draw_text_transformed(now_playing_x, now_playing_y + line_spacing, song_title, text_scale * 0.9, text_scale * 0.9, 0);

// Artist credit
draw_set_color(c_black);
draw_text_transformed(now_playing_x + 1, now_playing_y + line_spacing * 2 + 1, "by " + song_artist, text_scale * 0.75, text_scale * 0.75, 0);
draw_set_color(make_color_rgb(180, 180, 180)); // Light gray
draw_text_transformed(now_playing_x, now_playing_y + line_spacing * 2, "by " + song_artist, text_scale * 0.75, text_scale * 0.75, 0);

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);