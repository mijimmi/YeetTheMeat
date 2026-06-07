// === CONTROLS PHASE: P1 only (single) or P1 + P2 (multi) ===
if (instruction_alpha > 0.01 && current_phase == "controls") {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var cx = gui_w / 2;
    var cy = gui_h / 2 + 80;
    var multiplayer = is_multiplayer_mode();
    var anim_t = controls_anim_timer;

    var card_w = multiplayer ? 470 : 620;
    var card_h = 340;
    var gap = 60;

    // Slide-in from sides (multi) or scale-up from center (single)
    var slide = max(0, 1 - anim_t * 0.04);
    var p1_off_x = multiplayer ? -(card_w / 2 + gap / 2) - slide * 120 : 0;
    var p2_off_x = (card_w / 2 + gap / 2) + slide * 120;

    // --- Heading above the cards (animated bob) ---
    var head_bob = sin(anim_t * 0.06) * 5;
    var heading_y = cy - card_h / 2 - 58 + head_bob;
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var heading = multiplayer ? "HOW TO PLAY TOGETHER" : "HOW TO PLAY";
    var head_s = 2.3 + sin(anim_t * 0.05) * 0.05;
    draw_set_alpha(instruction_alpha);
    draw_set_color(c_black);
    for (var hx = -3; hx <= 3; hx += 3) {
        for (var hy = -3; hy <= 3; hy += 3) {
            if (hx != 0 || hy != 0) {
                draw_text_transformed(cx + hx, heading_y + hy, heading, head_s, head_s, 0);
            }
        }
    }
    draw_set_color(c_white);
    draw_text_transformed(cx, heading_y, heading, head_s, head_s, 0);

    // --- Control rows ---
    var p1_rows = [
        ["Move",   "Stick", "WASD"],
        ["Action", "X",     "E"],
        ["Drop",   "Y",     "R"],
        ["Cancel", "B",     "Shift"],
    ];
    var p2_rows = [
        ["Move",   "Stick", "IJKL"],
        ["Action", "X",     "U"],
        ["Drop",   "Y",     "O"],
        ["Cancel", "B",     "Y"],
    ];

    draw_control_card(cx + p1_off_x, cy, card_w, card_h, "PLAYER 1", make_color_rgb(210, 80, 80), p1_rows, instruction_alpha, anim_t, 0);

    if (multiplayer) {
        draw_control_card(cx + p2_off_x, cy, card_w, card_h, "PLAYER 2", make_color_rgb(225, 150, 50), p2_rows, instruction_alpha, anim_t, 1);
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    // --- "Press to continue" prompt (appears only after a short read) ---
    var cont_y = cy + card_h / 2 + 40;
    if (anim_t >= 90) {
        var cont_text = "Press " + tut_action_key() + " to continue";
        var cont_scale = 1.7;
        var cont_blink = 0.7 + sin(anim_t * 0.12) * 0.3;
        draw_set_alpha(instruction_alpha * cont_blink);
        draw_set_color(c_black);
        for (var cnx = -2; cnx <= 2; cnx += 2) {
            for (var cny = -2; cny <= 2; cny += 2) {
                if (cnx != 0 || cny != 0) {
                    draw_text_transformed(cx + cnx, cont_y + cny, cont_text, cont_scale, cont_scale, 0);
                }
            }
        }
        draw_set_color(make_color_rgb(255, 235, 170));
        draw_text_transformed(cx, cont_y, cont_text, cont_scale, cont_scale, 0);
    } else {
        // Brief "take a look" hint before the continue prompt unlocks
        var look_text = "Take a look at your controls...";
        draw_set_alpha(instruction_alpha * 0.85);
        draw_set_color(make_color_rgb(230, 215, 180));
        draw_text_transformed(cx, cont_y, look_text, 1.4, 1.4, 0);
    }

    // --- Skip hint below the continue prompt ---
    var c_skip_text = "Stuck? Press " + tut_select_key() + " to skip";
    var c_skip_scale = 1.1;
    var c_skip_y = cont_y + 40;
    var skip_blink = 0.65 + sin(anim_t * 0.08) * 0.25;
    draw_set_alpha(instruction_alpha * skip_blink);
    draw_set_color(make_color_rgb(200, 180, 150));
    draw_text_transformed(cx, c_skip_y, c_skip_text, c_skip_scale, c_skip_scale, 0);

    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

if (instruction_alpha > 0.01 && current_phase != "complete" && current_phase != "controls") {
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var text_scale = 2.5;
    var text_w = string_width(instruction_text_full) * text_scale;
    var text_h = string_height(instruction_text_full) * text_scale;

    var gui_h = display_get_gui_height();
    var center_y = gui_h / 2;
    var bottom_y = gui_h;
    var base_y = (center_y + bottom_y) / 2 + 55;

    // Gentle idle bob
    var bob = sin(box_bob_timer) * 4;
    var card_cy = base_y + bob;

    // Card bounds (text centered; Istar's portrait sits beside it on the left)
    var pad        = box_padding;
    var box_x1     = instruction_x - (text_w / 2) - pad;
    var box_y1     = card_cy - (text_h / 2) - pad;
    var box_x2     = instruction_x + (text_w / 2) + pad;
    var box_y2     = card_cy + (text_h / 2) + pad;
    var rad        = 26;

    // --- Soft drop shadow ---
    draw_set_alpha(0.22 * instruction_alpha);
    draw_set_color(c_black);
    draw_roundrect_ext(box_x1 + 8, box_y1 + 10, box_x2 + 8, box_y2 + 10, rad, rad, false);

    // --- Cream card fill ---
    draw_set_alpha(box_alpha * instruction_alpha);
    draw_set_color(box_color);
    draw_roundrect_ext(box_x1, box_y1, box_x2, box_y2, rad, rad, false);

    // --- Double brown border ---
    draw_set_alpha(instruction_alpha);
    draw_set_color(highlight_color);
    draw_roundrect_ext(box_x1, box_y1, box_x2, box_y2, rad, rad, true);
    draw_roundrect_ext(box_x1 + 4, box_y1 + 4, box_x2 - 4, box_y2 - 4, rad - 4, rad - 4, true);

    // --- Istar portrait (spr_P2icon), large, sitting beside the box on the left ---
    // spr_P2icon is 256x256, centered origin.
    var icon_scale   = 0.78;
    var icon_w       = 256 * icon_scale;   // ~200px
    var icon_h       = 256 * icon_scale;
    var portrait_bob = sin(box_bob_timer * 1.25) * 4;          // her own gentle bob
    var portrait_cx  = box_x1 - icon_w * 0.34;                 // overlaps the box's left edge a touch
    var portrait_cy  = card_cy + portrait_bob;

    // --- "ISTAR" speaker nametag pill above the portrait ---
    var name_text  = "ISTAR";
    var name_scale = 1.5;
    var name_w     = string_width(name_text) * name_scale;
    var name_h     = string_height(name_text) * name_scale;
    var name_cx    = portrait_cx;
    var name_cy    = portrait_cy - icon_h * 0.5 - name_h * 0.5 + 6;
    var name_x1    = name_cx - name_w / 2 - 16;
    var name_x2    = name_cx + name_w / 2 + 16;
    var name_y1    = name_cy - name_h / 2 - 7;
    var name_y2    = name_cy + name_h / 2 + 7;

    draw_set_color(highlight_color);
    draw_roundrect_ext(name_x1, name_y1, name_x2, name_y2, 16, 16, false);
    draw_set_color(box_color);
    draw_roundrect_ext(name_x1, name_y1, name_x2, name_y2, 16, 16, true);
    draw_set_color(box_color);
    draw_text_transformed(name_cx, name_cy, name_text, name_scale, name_scale, 0);

    // Portrait itself (drawn over the box edge for a nice overlap)
    draw_set_alpha(instruction_alpha);
    draw_sprite_ext(spr_P2icon, 0, portrait_cx, portrait_cy,
                    icon_scale, icon_scale, 0, c_white, 1);

    // --- Instruction text (brown ink, typing effect) ---
    draw_set_color(text_color);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_transformed(instruction_x, card_cy, instruction_text_display, text_scale, text_scale, 0);

    // --- Skip hint below the card ---
    var skip_text  = "Stuck? Press " + tut_select_key() + " to skip";
    var skip_scale = 1.3;
    var skip_y     = box_y2 + 34;
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    for (var _sx = -2; _sx <= 2; _sx += 2) {
        for (var _sy = -2; _sy <= 2; _sy += 2) {
            if (_sx != 0 || _sy != 0) {
                draw_text_transformed(instruction_x + _sx, skip_y + _sy, skip_text, skip_scale, skip_scale, 0);
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

    // === Animated sparkle stars around headline (bigger) ===
    var star_positions = [
        [cc_x1 + 40, cc_y1 + 36],
        [cc_x2 - 40, cc_y1 + 36],
        [cc_x1 + 120, cc_y1 + 90],
        [cc_x2 - 120, cc_y1 + 90],
        [cc_x1 + 70, cc_y1 + 130],
        [cc_x2 - 70, cc_y1 + 130],
    ];
    var star_color = make_color_rgb(255, 210, 80);
    for (var si = 0; si < 6; si++) {
        var sx = star_positions[si][0];
        var sy = star_positions[si][1];
        var star_phase = complete_star_timer * 0.07 + si * 1.4;
        var star_s = 1.1 + sin(star_phase) * 0.35;
        var star_rot = complete_star_timer * 1.5 + si * 45;
        var star_alpha = 0.55 + sin(star_phase + 1.0) * 0.4;
        draw_set_alpha(star_alpha);
        draw_set_color(star_color);
        // Draw a simple 4-point star as two crossed lines
        var arm = 26 * star_s;
        var arm2 = arm * 0.55;
        var rcos = dcos(star_rot);
        var rsin = dsin(star_rot);
        draw_line_width(sx - arm * rcos, sy + arm * rsin, sx + arm * rcos, sy - arm * rsin, 5);
        draw_line_width(sx - arm * (-rsin), sy + arm * rcos, sx + arm * (-rsin), sy - arm * rcos, 5);
        draw_line_width(sx - arm2 * dcos(star_rot + 45), sy + arm2 * dsin(star_rot + 45),
                        sx + arm2 * dcos(star_rot + 45), sy - arm2 * dsin(star_rot + 45), 4);
        draw_line_width(sx - arm2 * dcos(star_rot + 135), sy + arm2 * dsin(star_rot + 135),
                        sx + arm2 * dcos(star_rot + 135), sy - arm2 * dsin(star_rot + 135), 4);
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

    // === Warning text at the bottom of the card (no box) ===
    var warn_y = cc_y2 - 62;
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