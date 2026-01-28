// Draw GUI Event - Inventory Display

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
        
        // Left arrow (LB / Q) - Previous page
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
            
            // Draw "LB" text
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
        
        // Right arrow (RB / E) - Next page
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
            
            // Draw "RB" text
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
// === RECIPE BOOK HINT (Bottom Center - only when book is closed) ===
else if (sprite_exists(spr_recipeicon)) {
    var hint_x = gui_width / 2;
    var icon_alpha = 0.7 + sin(anim_timer * 0.03) * 0.1; // Subtle pulse for icon
    var text_alpha = 0.9; // More opaque text
    var hint_scale = 0.25;  // Small icon
    
    // Calculate icon height for proper spacing
    var icon_height = sprite_get_height(spr_recipeicon) * hint_scale;
    
    // Draw recipe icon at bottom (lower)
    var icon_y = gui_height - 4;
    draw_set_alpha(icon_alpha);
    draw_sprite_ext(spr_recipeicon, 0, hint_x, icon_y, hint_scale, hint_scale, 0, c_white, icon_alpha);
    
    // Draw "SELECT" text stacked on top of icon (no overlap)
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    
    var text_scale = 1.3;  // Bigger text
    var text_y = icon_y - icon_height / 2 + 2;  // Lower (closer to icon)
    
    // Black outline (bigger)
    draw_set_alpha(text_alpha);
    draw_set_color(c_black);
    for (var ox = -2; ox <= 2; ox++) {
        for (var oy = -2; oy <= 2; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text_transformed(hint_x + ox, text_y + oy, "SELECT", text_scale, text_scale, 0);
            }
        }
    }
    
    // White text
    draw_set_color(c_white);
    draw_text_transformed(hint_x, text_y, "SELECT", text_scale, text_scale, 0);
    
    draw_set_alpha(1);
}

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
