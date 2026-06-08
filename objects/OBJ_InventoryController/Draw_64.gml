// Draw GUI Event - Inventory Display

// Don't draw if scoreboard is showing
if (instance_exists(OBJ_Scoring) && OBJ_Scoring.show_results) {
    exit;
}

var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

// === UPDATE ANIMATION ===
anim_timer += 1;
var bob_offset = sin(anim_timer * anim_bob_speed) * anim_bob_amount;
var breathe_scale = 1 + sin(anim_timer * anim_breathe_speed) * anim_breathe_amount;

// Function to draw a hand-drawn style box
function draw_handdrawn_box(bx, by, bw, bh, fill_col, fill_alpha, border_col, border_width, wobble, segments) {
    // Draw filled background with slight wobble
    draw_set_alpha(fill_alpha);
    draw_set_color(fill_col);
    draw_rectangle(bx + 2, by + 2, bx + bw - 2, by + bh - 2, false);
    draw_set_alpha(1);
    
    // Draw hand-drawn border lines
    draw_set_color(border_col);
    
    // We'll draw each side as a series of small line segments with random offsets
    var seed = bx + by; // Consistent seed per box
    random_set_seed(seed);
    
    for (var t = 0; t < border_width; t++) {
        var offset = t * 0.5;
        
        // Top edge
        var prev_x = bx + offset;
        var prev_y = by + offset + random_range(-wobble * 0.3, wobble * 0.3);
        for (var i = 1; i <= segments; i++) {
            var next_x = bx + offset + (bw - offset * 2) * (i / segments);
            var next_y = by + offset + random_range(-wobble * 0.5, wobble * 0.5);
            draw_line_width(prev_x, prev_y, next_x, next_y, 2);
            prev_x = next_x;
            prev_y = next_y;
        }
        
        // Bottom edge
        prev_x = bx + offset;
        prev_y = by + bh - offset + random_range(-wobble * 0.3, wobble * 0.3);
        for (var i = 1; i <= segments; i++) {
            var next_x = bx + offset + (bw - offset * 2) * (i / segments);
            var next_y = by + bh - offset + random_range(-wobble * 0.5, wobble * 0.5);
            draw_line_width(prev_x, prev_y, next_x, next_y, 2);
            prev_x = next_x;
            prev_y = next_y;
        }
        
        // Left edge
        prev_x = bx + offset + random_range(-wobble * 0.3, wobble * 0.3);
        prev_y = by + offset;
        for (var i = 1; i <= segments; i++) {
            var next_x = bx + offset + random_range(-wobble * 0.5, wobble * 0.5);
            var next_y = by + offset + (bh - offset * 2) * (i / segments);
            draw_line_width(prev_x, prev_y, next_x, next_y, 2);
            prev_x = next_x;
            prev_y = next_y;
        }
        
        // Right edge
        prev_x = bx + bw - offset + random_range(-wobble * 0.3, wobble * 0.3);
        prev_y = by + offset;
        for (var i = 1; i <= segments; i++) {
            var next_x = bx + bw - offset + random_range(-wobble * 0.5, wobble * 0.5);
            var next_y = by + offset + (bh - offset * 2) * (i / segments);
            draw_line_width(prev_x, prev_y, next_x, next_y, 2);
            prev_x = next_x;
            prev_y = next_y;
        }
    }
}

// === PLAYER 1 INVENTORY (Bottom Left) ===
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && instance_exists(p1)) {
    // Position from bottom-left with padding (with subtle bob)
    var p1_x = ui_margin_x;
    var p1_y = gui_height - ui_margin_y - box_height - 20 + bob_offset;
    
    // Draw player icon (with subtle breathe)
    var icon_center_y = p1_y + box_height / 2;
    if (sprite_exists(spr_P1icon)) {
        var icon_breathe = icon_scale * (1 + sin(anim_timer * anim_breathe_speed * 0.8) * 0.02);
        draw_sprite_ext(spr_P1icon, 0, p1_x + 24, icon_center_y, icon_breathe, icon_breathe, 0, c_white, 1);
    } else {
        // Fallback: draw P1 text
        draw_set_font(fnt_winkle);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(p1_x + 24, icon_center_y, "P1");
    }
    
    // Inventory box position (with spacing from icon)
    var box_x = p1_x + 48 + icon_spacing;
    var box_y = p1_y;
    
    // Draw "P1" label above the box (dark red)
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(make_color_rgb(180, 40, 40));
    draw_text_transformed(box_x + box_width / 2, box_y - 6, "P1", 1.6, 1.6, 0);
    
    // Draw hand-drawn box
    draw_handdrawn_box(box_x, box_y, box_width, box_height, box_color, box_alpha, box_border_color, box_border_width, wobble_amount, line_segments);
    
    // Draw held item
    var held = p1.held_item;
    if (held != noone && instance_exists(held)) {
        // Draw item sprite centered in box (with subtle breathing)
        var item_spr = held.sprite_index;
        var item_frame = held.image_index;
        var center_x = box_x + box_width / 2;
        var center_y = box_y + box_height / 2;
        
        // Special case: Plate with food - show the food/dish sprite instead
        if (held.object_index == OBJ_Plate && variable_instance_exists(held, "has_food") && held.has_food) {
            if (variable_instance_exists(held, "food_on_plate") && held.food_on_plate != noone && instance_exists(held.food_on_plate)) {
                item_spr = held.food_on_plate.sprite_index;
                item_frame = held.food_on_plate.image_index;
            }
        }
        
        var animated_scale = item_scale * breathe_scale;
        draw_sprite_ext(item_spr, item_frame, center_x, center_y, animated_scale, animated_scale, 0, c_white, 1);
        
        // Draw item name BELOW the box (with black outline)
        var item_name = get_item_name(held);
        var text_x = center_x;
        var text_y = box_y + box_height + 4;
        draw_set_font(fnt_winkle);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        // Draw black outline (all 8 directions)
        draw_set_color(c_black);
        draw_text_transformed(text_x - 1, text_y - 1, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x + 1, text_y - 1, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x - 1, text_y + 1, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x + 1, text_y + 1, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x - 1, text_y, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x + 1, text_y, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x, text_y - 1, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x, text_y + 1, item_name, 1.8, 1.8, 0);
        // Draw main text
        draw_set_color(c_white);
        draw_text_transformed(text_x, text_y, item_name, 1.8, 1.8, 0);
    } else {
        // Draw "Empty" text (with subtle pulse)
        draw_set_font(fnt_winkle);
        var empty_alpha = 0.5 + sin(anim_timer * 0.05) * 0.15;
        draw_set_color(merge_color(c_dkgray, c_gray, empty_alpha));
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed(box_x + box_width / 2, box_y + box_height / 2, "Empty", 1.0, 1.0, 0);
    }
}

// === PLAYER 2 INVENTORY (Bottom Right) ===
var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && instance_exists(p2)) {
    // P2 uses offset animation timing for visual interest
    var p2_bob_offset = sin((anim_timer + 30) * anim_bob_speed) * anim_bob_amount;
    var p2_breathe_scale = 1 + sin((anim_timer + 30) * anim_breathe_speed) * anim_breathe_amount;
    
    // Position from bottom-right with padding (with subtle bob)
    var p2_y = gui_height - ui_margin_y - box_height - 20 + p2_bob_offset;
    
    // Icon position (right side with padding)
    var icon_x = gui_width - ui_margin_x - 24;
    var icon_center_y = p2_y + box_height / 2;
    
    // Draw player icon (with subtle breathe)
    if (sprite_exists(spr_P2icon)) {
        var icon_breathe = icon_scale * (1 + sin((anim_timer + 30) * anim_breathe_speed * 0.8) * 0.02);
        draw_sprite_ext(spr_P2icon, 0, icon_x, icon_center_y, icon_breathe, icon_breathe, 0, c_white, 1);
    } else {
        // Fallback: draw P2 text
        draw_set_font(fnt_winkle);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(icon_x, icon_center_y, "P2");
    }
    
    // Inventory box position (to the left of icon with spacing)
    var box_x = gui_width - ui_margin_x - 48 - icon_spacing - box_width;
    var box_y = p2_y;
    
    // Draw "P2" label above the box (dark orange)
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(make_color_rgb(200, 120, 40));
    draw_text_transformed(box_x + box_width / 2, box_y - 6, "P2", 1.6, 1.6, 0);
    
    // Draw hand-drawn box
    draw_handdrawn_box(box_x, box_y, box_width, box_height, box_color, box_alpha, box_border_color, box_border_width, wobble_amount, line_segments);
    
    // Draw held item
    var held = p2.held_item;
    if (held != noone && instance_exists(held)) {
        // Draw item sprite centered in box (with subtle breathing)
        var item_spr = held.sprite_index;
        var item_frame = held.image_index;
        var center_x = box_x + box_width / 2;
        var center_y = box_y + box_height / 2;
        
        // Special case: Plate with food - show the food/dish sprite instead
        if (held.object_index == OBJ_Plate && variable_instance_exists(held, "has_food") && held.has_food) {
            if (variable_instance_exists(held, "food_on_plate") && held.food_on_plate != noone && instance_exists(held.food_on_plate)) {
                item_spr = held.food_on_plate.sprite_index;
                item_frame = held.food_on_plate.image_index;
            }
        }
        
        var animated_scale = item_scale * p2_breathe_scale;
        draw_sprite_ext(item_spr, item_frame, center_x, center_y, animated_scale, animated_scale, 0, c_white, 1);
        
        // Draw item name BELOW the box (with black outline)
        var item_name = get_item_name(held);
        var text_x = center_x;
        var text_y = box_y + box_height + 4;
        draw_set_font(fnt_winkle);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        // Draw black outline (all 8 directions)
        draw_set_color(c_black);
        draw_text_transformed(text_x - 1, text_y - 1, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x + 1, text_y - 1, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x - 1, text_y + 1, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x + 1, text_y + 1, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x - 1, text_y, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x + 1, text_y, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x, text_y - 1, item_name, 1.8, 1.8, 0);
        draw_text_transformed(text_x, text_y + 1, item_name, 1.8, 1.8, 0);
        // Draw main text
        draw_set_color(c_white);
        draw_text_transformed(text_x, text_y, item_name, 1.8, 1.8, 0);
    } else {
        // Draw "Empty" text (with subtle pulse)
        draw_set_font(fnt_winkle);
        var empty_alpha = 0.5 + sin((anim_timer + 30) * 0.05) * 0.15;
        draw_set_color(merge_color(c_dkgray, c_gray, empty_alpha));
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed(box_x + box_width / 2, box_y + box_height / 2, "Empty", 1.0, 1.0, 0);
    }
}

// === RECIPE BOOK (Fullscreen when open) ===
if (recipe_book_open && recipe_anim_progress > 0) {
    // Get current page sprite
    var page_sprite = spr_recipepg1;
    switch (recipe_current_page) {
        case 1: page_sprite = spr_recipepg1; break;
        case 2: page_sprite = spr_recipepg2; break;
        case 3: page_sprite = spr_recipepg3; break;
        case 4: page_sprite = spr_recipepg4; break;
    }
    
    // Animation: scale and alpha
    var anim_scale = recipe_anim_progress;
    var anim_alpha = recipe_anim_progress;
    
    // Slight bounce effect at the end of opening
    if (recipe_opening && recipe_anim_progress > 0.8) {
        anim_scale = 0.8 + (recipe_anim_progress - 0.8) * 1.5;
    }
    
    // Draw fullscreen recipe with animation
    if (sprite_exists(page_sprite)) {
        var base_scale_x = gui_width / sprite_get_width(page_sprite);
        var base_scale_y = gui_height / sprite_get_height(page_sprite);
        var final_scale_x = base_scale_x * anim_scale;
        var final_scale_y = base_scale_y * anim_scale;
        
        draw_sprite_ext(page_sprite, 0, gui_width / 2, gui_height / 2, final_scale_x, final_scale_y, 0, c_white, anim_alpha);
    }
    
    // Only draw UI elements when fully open
    if (recipe_anim_progress >= 1) {
        draw_set_font(fnt_winkle);
        
        // === PAGE INDICATOR (Top Center) ===
        var page_text = "Page " + string(recipe_current_page) + " of " + string(recipe_total_pages);
        var page_y = 30;
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        
        // Black outline
        draw_set_color(c_black);
        for (var ox = -2; ox <= 2; ox++) {
            for (var oy = -2; oy <= 2; oy++) {
                if (ox != 0 || oy != 0) {
                    draw_text_transformed(gui_width / 2 + ox, page_y + oy, page_text, 1.2, 1.2, 0);
                }
            }
        }
        draw_set_color(c_white);
        draw_text_transformed(gui_width / 2, page_y, page_text, 1.2, 1.2, 0);
        
        // === NAVIGATION HINTS (Left and Right) ===
        var nav_y = gui_height / 2;
        var nav_scale = 1.4;  // Bigger text
        var arrow_size = 16;  // Arrow triangle size
        
        // Left arrow (LT / Q) - Previous page
        if (recipe_current_page > 1) {
            var left_x = 180;  // More padding from edge
            
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            
            // Draw arrow triangle (pointing left)
            var arrow_x = left_x - 50;
            draw_set_color(c_black);
            draw_triangle(arrow_x + arrow_size + 2, nav_y - arrow_size - 2, 
                          arrow_x + arrow_size + 2, nav_y + arrow_size + 2, 
                          arrow_x - 2, nav_y, false);
            draw_set_color(c_white);
            draw_triangle(arrow_x + arrow_size, nav_y - arrow_size, 
                          arrow_x + arrow_size, nav_y + arrow_size, 
                          arrow_x, nav_y, false);
            
            // Draw "LT" text
            draw_set_color(c_black);
            for (var ox = -2; ox <= 2; ox++) {
                for (var oy = -2; oy <= 2; oy++) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(left_x + ox, nav_y - 20 + oy, "LT", nav_scale, nav_scale, 0);
                    }
                }
            }
            draw_set_color(c_white);
            draw_text_transformed(left_x, nav_y - 20, "LT", nav_scale, nav_scale, 0);
            
            // Draw "Previous Page" below
            draw_set_color(c_black);
            for (var ox = -2; ox <= 2; ox++) {
                for (var oy = -2; oy <= 2; oy++) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(left_x + ox, nav_y + 15 + oy, "Previous Page", nav_scale * 0.7, nav_scale * 0.7, 0);
                    }
                }
            }
            draw_set_color(c_white);
            draw_text_transformed(left_x, nav_y + 15, "Previous Page", nav_scale * 0.7, nav_scale * 0.7, 0);
        }
        
        // Right arrow (RT / E) - Next page
        if (recipe_current_page < recipe_total_pages) {
            var right_x = gui_width - 180;  // More padding from edge
            
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            
            // Draw arrow triangle (pointing right)
            var arrow_x = right_x + 50;
            draw_set_color(c_black);
            draw_triangle(arrow_x - arrow_size - 2, nav_y - arrow_size - 2, 
                          arrow_x - arrow_size - 2, nav_y + arrow_size + 2, 
                          arrow_x + 2, nav_y, false);
            draw_set_color(c_white);
            draw_triangle(arrow_x - arrow_size, nav_y - arrow_size, 
                          arrow_x - arrow_size, nav_y + arrow_size, 
                          arrow_x, nav_y, false);
            
            // Draw "RT" text
            draw_set_color(c_black);
            for (var ox = -2; ox <= 2; ox++) {
                for (var oy = -2; oy <= 2; oy++) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(right_x + ox, nav_y - 20 + oy, "RT", nav_scale, nav_scale, 0);
                    }
                }
            }
            draw_set_color(c_white);
            draw_text_transformed(right_x, nav_y - 20, "RT", nav_scale, nav_scale, 0);
            
            // Draw "Next Page" below
            draw_set_color(c_black);
            for (var ox = -2; ox <= 2; ox++) {
                for (var oy = -2; oy <= 2; oy++) {
                    if (ox != 0 || oy != 0) {
                        draw_text_transformed(right_x + ox, nav_y + 15 + oy, "Next Page", nav_scale * 0.7, nav_scale * 0.7, 0);
                    }
                }
            }
            draw_set_color(c_white);
            draw_text_transformed(right_x, nav_y + 15, "Next Page", nav_scale * 0.7, nav_scale * 0.7, 0);
        }
        
        // === DISH TUTORIAL SELECTION ===
        var sel_t = recipe_sel_pulse;

        var left_dish  = recipe_dish_at(recipe_current_page, 0);
        var right_dish = recipe_dish_at(recipe_current_page, 1);
        var side_cx   = [gui_width * 0.28, gui_width * 0.72];
        var side_dish = [left_dish, right_dish];

        var hl_w = gui_width * 0.30;
        var hl_h = gui_height * 0.66;
        var hl_cy = gui_height * 0.47;

        // Tint each selectable dish with a colored overlay:
        //   focused (not chosen) = soft cream wash, chosen = warm gold wash.
        for (var s = 0; s < 2; s++) {
            if (side_dish[s] == "") continue;

            var cx = side_cx[s];
            var fx1 = cx - hl_w / 2;
            var fx2 = cx + hl_w / 2;
            var fy1 = hl_cy - hl_h / 2;
            var fy2 = hl_cy + hl_h / 2;

            var is_focused  = (recipe_cursor_side == s);
            var is_selected = (recipe_selected_dish != "" && recipe_selected_dish == side_dish[s]);

            if (!is_focused && !is_selected) continue;

            var ov_col;
            var ov_alpha;
            if (is_selected) {
                ov_col = make_color_rgb(196, 86, 60);            // dialogue terracotta
                ov_alpha = 0.32 + sin(sel_t * 0.09) * 0.06;
            } else {
                ov_col = make_color_rgb(250, 241, 218);          // dialogue cream
                ov_alpha = 0.24 + sin(sel_t * 0.10) * 0.05;
            }

            // Colored overlay fill
            draw_set_alpha(ov_alpha);
            draw_set_color(ov_col);
            draw_roundrect_ext(fx1, fy1, fx2, fy2, 26, 26, false);
            draw_set_alpha(1);

            // "TUTORIAL" ribbon at the top of the chosen dish
            if (is_selected) {
                var rib_w = 150;
                var rib_y = fy1 - 4;
                draw_set_color(make_color_rgb(196, 86, 60));
                draw_roundrect_ext(cx - rib_w / 2, rib_y - 17, cx + rib_w / 2, rib_y + 17, 10, 10, false);
                draw_set_color(make_color_rgb(255, 240, 215));
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_set_font(fnt_winkle);
                draw_text_transformed(cx, rib_y, "TUTORIAL", 0.95, 0.95, 0);
            }
        }

        // === BIG SELECTION INDICATOR (Bottom) — styled like the dialogue boxes ===
        var focused_dish = recipe_dish_at(recipe_current_page, recipe_cursor_side);
        var btn_label = recipe_confirm_label();

        // Dialogue-box palette
        var dlg_cream  = make_color_rgb(250, 241, 218);
        var dlg_ink    = make_color_rgb(90, 55, 30);
        var dlg_border = make_color_rgb(124, 82, 46);
        var dlg_pill   = make_color_rgb(196, 86, 60);

        var prompt_txt;
        var is_focus_selected = (recipe_selected_dish != "" && recipe_selected_dish == focused_dish);
        if (is_focus_selected) {
            prompt_txt = "Cancel the " + recipe_dish_label(focused_dish) + " tutorial";
        } else {
            prompt_txt = "Learn how to make " + recipe_dish_label(focused_dish);
        }

        draw_set_font(fnt_winkle);

        // Measure the pill + prompt so the whole group can be centered
        var prompt_scale = 1.85;
        var pill_scale   = 1.9;
        var pill_tw   = string_width(btn_label) * pill_scale;
        var pill_box_w = pill_tw + 48;
        var prompt_w  = string_width(prompt_txt) * prompt_scale;
        var grp_gap   = 30;
        var grp_w     = pill_box_w + grp_gap + prompt_w;

        var sub_txt = "Choose with Left or Right. It begins when you close the book.";
        var sub_scale = 1.0;

        var banner_cy = gui_height - 116;
        var ban_w = max(grp_w + 100, string_width(sub_txt) * sub_scale + 80);
        ban_w = max(ban_w, gui_width * 0.55);
        var ban_h = 124;
        var bx1 = gui_width / 2 - ban_w / 2;
        var bx2 = gui_width / 2 + ban_w / 2;
        var by1 = banner_cy - ban_h / 2;
        var by2 = banner_cy + ban_h / 2;

        // Card: cream fill + brown double border + soft shadow
        draw_set_alpha(0.26);
        draw_set_color(c_black);
        draw_roundrect_ext(bx1 + 6, by1 + 7, bx2 + 6, by2 + 7, 24, 24, false);
        draw_set_alpha(0.97);
        draw_set_color(dlg_cream);
        draw_roundrect_ext(bx1, by1, bx2, by2, 24, 24, false);
        draw_set_alpha(1);
        draw_set_color(dlg_border);
        draw_roundrect_ext(bx1, by1, bx2, by2, 24, 24, true);
        draw_roundrect_ext(bx1 + 4, by1 + 4, bx2 - 4, by2 - 4, 20, 20, true);

        var main_y = banner_cy - 20;
        var grp_left = gui_width / 2 - grp_w / 2;

        // Button pill
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        var pill_cx = grp_left + pill_box_w / 2;
        var pill_pulse = 1 + sin(sel_t * 0.1) * 0.05;
        draw_set_color(dlg_pill);
        draw_roundrect_ext(pill_cx - (pill_box_w / 2) * pill_pulse, main_y - 28 * pill_pulse,
                           pill_cx + (pill_box_w / 2) * pill_pulse, main_y + 28 * pill_pulse, 14, 14, false);
        draw_set_color(dlg_cream);
        draw_text_transformed(pill_cx, main_y, btn_label, pill_scale, pill_scale, 0);

        // Prompt text
        draw_set_halign(fa_left);
        draw_set_color(dlg_ink);
        draw_text_transformed(grp_left + pill_box_w + grp_gap, main_y, prompt_txt, prompt_scale, prompt_scale, 0);

        // Sub-hint underneath (centered)
        draw_set_halign(fa_center);
        draw_set_color(dlg_border);
        draw_text_transformed(gui_width / 2, banner_cy + 36, sub_txt, sub_scale, sub_scale, 0);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_color(c_white);

        // === CLOSE HINT (Bottom Center) ===
        var close_text = "SELECT to close";
        var close_y = gui_height - 25;
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        
        // Black outline
        draw_set_color(c_black);
        for (var ox = -2; ox <= 2; ox++) {
            for (var oy = -2; oy <= 2; oy++) {
                if (ox != 0 || oy != 0) {
                    draw_text_transformed(gui_width / 2 + ox, close_y + oy, close_text, 1.0, 1.0, 0);
                }
            }
        }
        draw_set_color(c_white);
        draw_text_transformed(gui_width / 2, close_y, close_text, 1.0, 1.0, 0);
    }
}
// === RECIPE BOOK HINT (Bottom Center) ===
// Always draw the icon + SELECT when the book is closed (independent of the
// "learn how to cook" card above it so both are visible at the same time).
if (sprite_exists(spr_recipeicon) && !recipe_book_open
    && !instance_exists(OBJ_TutorialManager)
    && !(instance_exists(OBJ_HintController)
         && (OBJ_HintController.guide_active || OBJ_HintController.guide_done_flash > 0))) {
    var hint_x = gui_width / 2;
    var icon_alpha = 0.7 + sin(anim_timer * 0.03) * 0.1;
    var hint_scale = 0.25;
    var icon_height = sprite_get_height(spr_recipeicon) * hint_scale;
    var icon_y = gui_height - 4;
    draw_sprite_ext(spr_recipeicon, 0, hint_x, icon_y, hint_scale, hint_scale, 0, c_white, icon_alpha);

    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    var text_scale = 1.3;
    var text_y = icon_y - icon_height / 2 + 2;
    draw_set_alpha(0.9);
    draw_set_color(c_black);
    for (var ox = -2; ox <= 2; ox++) {
        for (var oy = -2; oy <= 2; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text_transformed(hint_x + ox, text_y + oy, "SELECT", text_scale, text_scale, 0);
            }
        }
    }
    draw_set_color(c_white);
    draw_text_transformed(hint_x, text_y, "SELECT", text_scale, text_scale, 0);
    draw_set_alpha(1);
}

// === "LEARN HOW TO COOK" FIRST-OPEN INDICATOR ===
// Floats above the recipe icon; disappears the first time the book is opened.
if (!recipe_book_open && !recipe_hint_dismissed
    && !instance_exists(OBJ_TutorialManager)
    && !(instance_exists(OBJ_HintController) && OBJ_HintController.guide_active)) {

    var dlg_cream  = make_color_rgb(250, 241, 218);
    var dlg_ink    = make_color_rgb(90, 55, 30);
    var dlg_border = make_color_rgb(124, 82, 46);
    var dlg_pill   = make_color_rgb(196, 86, 60);

    var rh_x = gui_width / 2;

    // The recipe icon is 512px tall drawn at scale 0.25 → ~128px, bottom-
    // anchored at gui_height-4, so its top ≈ gui_height-68.
    // SELECT text sits a bit above that. We place the card bottom edge at
    // gui_height-110 so the whole recipe-icon cluster remains visible below.
    var bounce   = sin(anim_timer * 0.07) * 5;
    var card_w   = 470;
    var card_h   = 52;
    // card bottom stays fixed; center floats with bounce
    var card_bot = gui_height - 114;
    var card_cy  = card_bot - card_h / 2 + bounce;
    var cx1 = rh_x - card_w / 2;
    var cx2 = rh_x + card_w / 2;
    var cy1 = card_cy - card_h / 2;
    var cy2 = card_cy + card_h / 2;

    // Shadow
    draw_set_alpha(0.22);
    draw_set_color(c_black);
    draw_roundrect_ext(cx1 + 5, cy1 + 6, cx2 + 5, cy2 + 6, 18, 18, false);
    // Cream card
    draw_set_alpha(0.97);
    draw_set_color(dlg_cream);
    draw_roundrect_ext(cx1, cy1, cx2, cy2, 18, 18, false);
    draw_set_alpha(1);
    draw_set_color(dlg_pill);
    draw_roundrect_ext(cx1, cy1, cx2, cy2, 18, 18, true);
    draw_roundrect_ext(cx1 + 3, cy1 + 3, cx2 - 3, cy2 - 3, 15, 15, true);

    // Label
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(dlg_ink);
    draw_text_transformed(rh_x, card_cy, "Learn how to cook different dishes!", 1.55, 1.55, 0);

    // Little arrow pointing down toward the recipe icon
    var arr_cx = rh_x;
    var arr_ty = cy2;
    draw_set_color(dlg_pill);
    draw_triangle(arr_cx - 10, arr_ty, arr_cx + 10, arr_ty, arr_cx, arr_ty + 14, false);

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
