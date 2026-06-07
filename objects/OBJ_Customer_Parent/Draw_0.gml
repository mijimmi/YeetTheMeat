// Draw customer sprite
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Draw thought bubble with order
if ((customer_state == "waiting" || customer_state == "leaving") && thought_bubble_alpha > 0) {

    var patience = min(wait_timer / max_wait_time, 1);

    // Dialogue-box palette
    var bub_fill   = make_color_rgb(250, 241, 218);  // cream
    var bub_ink    = make_color_rgb(124, 82, 46);    // brown border
    // Border shifts brown -> red as the customer loses patience
    var bub_border = merge_color(bub_ink, make_color_rgb(206, 58, 50), patience);
    // As the customer gets angry the border thickens and pulses so it's far
    // more visible (thin/calm normally, chunky red when patience runs low).
    var anger = clamp((patience - 0.55) / 0.45, 0, 1);
    var border_w   = 2 + (3.5 + sin(current_time * 0.014) * 1.2) * anger;
    // The bubble fill warms from cream to a strong red as anger rises, and gets
    // more opaque so the colour is clearly visible (not washed out).
    var bub_fill_now = merge_color(bub_fill, make_color_rgb(214, 48, 40), anger);
    var bub_fill_a   = 0.55 + anger * 0.42;

    var a = thought_bubble_alpha;

    // Helper: rounded bubble with a soft, translucent cream fill and a thin
    // tinted border. The order sprites are drawn separately at full opacity so
    // they stay readable while the bubble itself is unobtrusive.
    var _draw_bubble = function(cx, cy, hw, hh, rad, fill, border, bw, alpha, fillf) {
        var x1 = cx - hw, x2 = cx + hw, y1 = cy - hh, y2 = cy + hh;
        // Soft shadow
        draw_set_alpha(0.10 * alpha);
        draw_set_color(c_black);
        draw_roundrect_ext(x1 + 3, y1 + 4, x2 + 3, y2 + 4, rad, rad, false);
        // Fill (opacity rises with anger so the red tint reads clearly)
        draw_set_alpha(fillf * alpha);
        draw_set_color(fill);
        draw_roundrect_ext(x1, y1, x2, y2, rad, rad, false);
        // Thin border
        draw_set_alpha(0.85 * alpha);
        draw_set_color(border);
        var steps = max(1, round(bw));
        for (var b = 0; b < steps; b++) {
            draw_roundrect_ext(x1 + b, y1 + b, x2 - b, y2 - b, max(2, rad - b), max(2, rad - b), true);
        }
        draw_set_alpha(1);
    };

    if (has_second_order) {
        // === WIDE BUBBLE FOR TWO ORDERS ===
        var bubble_cx = x;
        var bubble_cy = y - 84;
        var bub_w     = 60;          // half-width
        var bub_h     = 32;          // half-height
        var spr_scale = 0.64;
        var gap       = 60;          // distance between the two item slots

        // Main bubble
        _draw_bubble(bubble_cx, bubble_cy, bub_w, bub_h, 20, bub_fill_now, bub_border, border_w, a, bub_fill_a);

        // Soft divider between the two items
        draw_set_alpha(a * 0.30);
        draw_set_color(bub_ink);
        draw_line_width(bubble_cx, bubble_cy - bub_h + 9, bubble_cx, bubble_cy + bub_h - 9, 2);
        draw_set_alpha(1);

        // Order 1 (left)
        if (order_sprite != noone) {
            var col1 = has_been_served ? c_gray : c_white;
            var a1   = has_been_served ? a * 0.6 : a;
            draw_sprite_ext(order_sprite, 0, bubble_cx - gap * 0.5, bubble_cy, spr_scale, spr_scale, 0, col1, a1);
            if (has_been_served) {
                draw_set_alpha(a);
                draw_set_color(make_color_rgb(96, 150, 86));
                draw_line_width(bubble_cx - gap * 0.5 - 12, bubble_cy + 9, bubble_cx - gap * 0.5 - 3, bubble_cy + 17, 3);
                draw_line_width(bubble_cx - gap * 0.5 - 3, bubble_cy + 17, bubble_cx - gap * 0.5 + 14, bubble_cy - 13, 3);
                draw_set_alpha(1);
            }
        }

        // Order 2 (right)
        if (order_sprite2 != noone) {
            var col2 = has_been_served2 ? c_gray : c_white;
            var a2   = has_been_served2 ? a * 0.6 : a;
            draw_sprite_ext(order_sprite2, 0, bubble_cx + gap * 0.5, bubble_cy, spr_scale, spr_scale, 0, col2, a2);
            if (has_been_served2) {
                draw_set_alpha(a);
                draw_set_color(make_color_rgb(96, 150, 86));
                draw_line_width(bubble_cx + gap * 0.5 - 12, bubble_cy + 9, bubble_cx + gap * 0.5 - 3, bubble_cy + 17, 3);
                draw_line_width(bubble_cx + gap * 0.5 - 3, bubble_cy + 17, bubble_cx + gap * 0.5 + 14, bubble_cy - 13, 3);
                draw_set_alpha(1);
            }
        }

    } else {
        // === SINGLE-ORDER BUBBLE ===
        var bubble_x = x;
        var bubble_y = y - 82;
        var bub_hw   = 32;
        var bub_hh   = 30;

        // Main bubble
        _draw_bubble(bubble_x, bubble_y, bub_hw, bub_hh, 18, bub_fill_now, bub_border, border_w, a, bub_fill_a);

        if (order_sprite != noone) {
            draw_sprite_ext(order_sprite, 0, bubble_x, bubble_y, 0.82, 0.82, 0, c_white, a);
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Debug: Show state
/*
draw_set_color(c_white);
draw_text(x, y - 80, customer_state);
draw_text(x, y - 70, order_name);
*/