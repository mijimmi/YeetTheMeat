// === DISH TUTORIAL GUIDE PANEL (Draw GUI) ===
// Anchored along the TOP-CENTRE of the screen: the top-left holds the score
// card, the top-right holds the kwek-kwek station / music widget, and the
// bottom corners hold the player inventories, so the centre top is the only
// spot that stays clear of the kitchen and HUD.
// Styled to match the in-game dialogue boxes (cream card, brown ink).

if (!guide_active && guide_done_flash <= 0) exit;

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

draw_set_font(fnt_winkle);

// Dialogue-box palette
var dlg_cream  = make_color_rgb(250, 241, 218);
var dlg_ink    = make_color_rgb(90, 55, 30);
var dlg_border = make_color_rgb(124, 82, 46);
var dlg_pill   = make_color_rgb(196, 86, 60);

if (guide_active && guide_step < array_length(guide_steps)) {
    var st = guide_steps[guide_step];
    var total = array_length(guide_steps);
    var step_num = guide_step + 1;

    var pw = 452;
    var cx = gui_w / 2;              // horizontal centre of the panel
    var px1 = cx - pw / 2;           // left edge
    var px2 = cx + pw / 2;           // right edge

    // Measure the wrapped step label so the panel can size to it
    var lbl_scale = 1.2;
    var lbl_w = pw - 50;
    var lbl_sep = 34;
    var lbl_h = string_height_ext(st.label, lbl_sep, lbl_w) * lbl_scale;

    // Anchor the panel to the BOTTOM-CENTRE (clear of the kitchen stations and
    // of the score/inventory HUD). Total height = 216 + label height.
    var total_h = 216 + lbl_h;
    var ty = gui_h - 30 - total_h;   // top of panel

    var y_head  = ty + 28;
    var y_name  = y_head + 48;
    var y_step  = y_name + 42;
    var y_label = y_step + 34;
    var y_pips  = y_label + lbl_h + 18;
    var y_hint  = y_pips + 24;
    var py2 = y_hint + 22;

    // Card: cream fill + brown double border + soft shadow
    draw_set_alpha(0.30);
    draw_set_color(c_black);
    draw_roundrect_ext(px1 + 7, ty + 8, px2 + 7, py2 + 8, 22, 22, false);
    draw_set_alpha(1);
    draw_set_color(dlg_cream);
    draw_roundrect_ext(px1, ty, px2, py2, 22, 22, false);
    draw_set_color(dlg_border);
    draw_roundrect_ext(px1, ty, px2, py2, 22, 22, true);
    draw_roundrect_ext(px1 + 4, ty + 4, px2 - 4, py2 - 4, 18, 18, true);

    // Header pill ("NOW COOKING") - centred
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var head_txt = "NOW COOKING";
    var head_scale = 0.88;
    var head_tw = string_width(head_txt) * head_scale;
    draw_set_color(dlg_pill);
    draw_roundrect_ext(cx - head_tw / 2 - 16, y_head - 18, cx + head_tw / 2 + 16, y_head + 18, 13, 13, false);
    draw_set_color(dlg_cream);
    draw_text_transformed(cx, y_head, head_txt, head_scale, head_scale, 0);

    // Dish name (big, centred)
    draw_set_color(dlg_ink);
    draw_text_transformed(cx, y_name, guide_name, 1.9, 1.9, 0);

    // Step counter
    draw_set_color(dlg_pill);
    draw_text_transformed(cx, y_step, "Step " + string(step_num) + " of " + string(total), 1.05, 1.05, 0);

    // Step instruction (wrapped, centred)
    draw_set_color(dlg_ink);
    draw_set_valign(fa_top);
    draw_text_ext_transformed(cx, y_label - lbl_h / 2, st.label, lbl_sep, lbl_w, lbl_scale, lbl_scale, 0);
    draw_set_valign(fa_middle);

    // Progress pips (centred row)
    var pip_gap = 19;
    var pip_r = 6;
    var pip_start = cx - (total - 1) * pip_gap / 2;
    for (var p = 0; p < total; p++) {
        if (p < step_num) draw_set_color(dlg_pill);
        else              draw_set_color(make_color_rgb(205, 185, 158));
        draw_circle(pip_start + p * pip_gap, y_pips, pip_r, false);
    }

    // Cancel hint
    draw_set_color(dlg_border);
    draw_text_transformed(cx, y_hint, "Open the recipe book to cancel", 0.78, 0.78, 0);
}
else if (guide_done_flash > 0) {
    var a = clamp(guide_done_flash / 60, 0, 1);
    var pw2 = 380;
    var qcx = gui_w / 2;
    var qx1 = qcx - pw2 / 2;
    var qx2 = qcx + pw2 / 2;
    var qy2 = gui_h - 30;
    var qy1 = qy2 - 76;
    var pop = 1 + sin((150 - guide_done_flash) * 0.12) * 0.05;

    // Cream card with a green accent border for the celebration
    draw_set_alpha(0.30 * a);
    draw_set_color(c_black);
    draw_roundrect_ext(qx1 + 7, qy1 + 8, qx2 + 7, qy2 + 8, 20, 20, false);
    draw_set_alpha(a);
    draw_set_color(dlg_cream);
    draw_roundrect_ext(qx1, qy1, qx2, qy2, 20, 20, false);
    draw_set_color(make_color_rgb(96, 150, 86));
    draw_roundrect_ext(qx1, qy1, qx2, qy2, 20, 20, true);
    draw_roundrect_ext(qx1 + 4, qy1 + 4, qx2 - 4, qy2 - 4, 16, 16, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(dlg_ink);
    draw_text_transformed((qx1 + qx2) / 2, (qy1 + qy2) / 2, guide_name + " done! Nice work!", pop * 1.1, pop * 1.1, 0);
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
