// Draw GUI Event - Inventory Display

var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

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
    // Position from bottom-left with padding
    var p1_x = ui_margin_x;
    var p1_y = gui_height - ui_margin_y - box_height - 20;
    
    // Draw player icon
    var icon_center_y = p1_y + box_height / 2;
    if (sprite_exists(spr_P1icon)) {
        draw_sprite_ext(spr_P1icon, 0, p1_x + 24, icon_center_y, icon_scale, icon_scale, 0, c_white, 1);
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
    draw_text_transformed(box_x + box_width / 2, box_y - 8, "P1", 2.2, 2.2, 0);
    
    // Draw hand-drawn box
    draw_handdrawn_box(box_x, box_y, box_width, box_height, box_color, box_alpha, box_border_color, box_border_width, wobble_amount, line_segments);
    
    // Draw held item
    var held = p1.held_item;
    if (held != noone && instance_exists(held)) {
        // Draw item sprite centered in box
        var item_spr = held.sprite_index;
        var item_frame = held.image_index;
        var center_x = box_x + box_width / 2;
        var center_y = box_y + box_height / 2;
        
        draw_sprite_ext(item_spr, item_frame, center_x, center_y, item_scale, item_scale, 0, c_white, 1);
        
        // Draw item name BELOW the box (with black outline)
        var item_name = get_item_name(held);
        var text_x = center_x;
        var text_y = box_y + box_height + 5;
        draw_set_font(fnt_winkle);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        // Draw black outline (all 8 directions)
        draw_set_color(c_black);
        draw_text_transformed(text_x - 1, text_y - 1, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x + 1, text_y - 1, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x - 1, text_y + 1, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x + 1, text_y + 1, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x - 1, text_y, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x + 1, text_y, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x, text_y - 1, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x, text_y + 1, item_name, 1.4, 1.4, 0);
        // Draw main text
        draw_set_color(c_white);
        draw_text_transformed(text_x, text_y, item_name, 1.4, 1.4, 0);
    } else {
        // Draw "Empty" text
        draw_set_font(fnt_winkle);
        draw_set_color(c_gray);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed(box_x + box_width / 2, box_y + box_height / 2, "Empty", 1.2, 1.2, 0);
    }
}

// === PLAYER 2 INVENTORY (Bottom Right) ===
var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && instance_exists(p2)) {
    // Position from bottom-right with padding
    var p2_y = gui_height - ui_margin_y - box_height - 20;
    
    // Icon position (right side with padding)
    var icon_x = gui_width - ui_margin_x - 24;
    var icon_center_y = p2_y + box_height / 2;
    
    // Draw player icon
    if (sprite_exists(spr_P2icon)) {
        draw_sprite_ext(spr_P2icon, 0, icon_x, icon_center_y, icon_scale, icon_scale, 0, c_white, 1);
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
    draw_text_transformed(box_x + box_width / 2, box_y - 8, "P2", 2.2, 2.2, 0);
    
    // Draw hand-drawn box
    draw_handdrawn_box(box_x, box_y, box_width, box_height, box_color, box_alpha, box_border_color, box_border_width, wobble_amount, line_segments);
    
    // Draw held item
    var held = p2.held_item;
    if (held != noone && instance_exists(held)) {
        // Draw item sprite centered in box
        var item_spr = held.sprite_index;
        var item_frame = held.image_index;
        var center_x = box_x + box_width / 2;
        var center_y = box_y + box_height / 2;
        
        draw_sprite_ext(item_spr, item_frame, center_x, center_y, item_scale, item_scale, 0, c_white, 1);
        
        // Draw item name BELOW the box (with black outline)
        var item_name = get_item_name(held);
        var text_x = center_x;
        var text_y = box_y + box_height + 5;
        draw_set_font(fnt_winkle);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        // Draw black outline (all 8 directions)
        draw_set_color(c_black);
        draw_text_transformed(text_x - 1, text_y - 1, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x + 1, text_y - 1, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x - 1, text_y + 1, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x + 1, text_y + 1, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x - 1, text_y, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x + 1, text_y, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x, text_y - 1, item_name, 1.4, 1.4, 0);
        draw_text_transformed(text_x, text_y + 1, item_name, 1.4, 1.4, 0);
        // Draw main text
        draw_set_color(c_white);
        draw_text_transformed(text_x, text_y, item_name, 1.4, 1.4, 0);
    } else {
        // Draw "Empty" text
        draw_set_font(fnt_winkle);
        draw_set_color(c_gray);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed(box_x + box_width / 2, box_y + box_height / 2, "Empty", 1.2, 1.2, 0);
    }
}

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
