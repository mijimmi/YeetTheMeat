// Draw customer sprite
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Draw thought bubble with order
if ((customer_state == "waiting" || customer_state == "leaving") && thought_bubble_alpha > 0) {

    var patience     = min(wait_timer / max_wait_time, 1);
    var bubble_color = merge_color(c_white, make_color_rgb(255, 100, 100), patience);

    if (has_second_order) {
        // === WIDE BUBBLE FOR TWO ORDERS ===
        var bubble_cx = x;           // centre of bubble
        var bubble_cy = y - 95;
        var bub_w     = 85;         // half-width of the rectangle body
        var bub_h     = 44;          // half-height
        var spr_scale = 0.85;        // sprite scale inside bubble
        var gap       = 64;          // horizontal gap between the two sprites

        draw_set_alpha(thought_bubble_alpha * 0.85);
        draw_set_color(bubble_color);
        // Rounded-rectangle approximation: circle + two rects
        draw_ellipse(bubble_cx - bub_w, bubble_cy - bub_h,
                     bubble_cx + bub_w, bubble_cy + bub_h, false);
        draw_set_alpha(thought_bubble_alpha * 0.85);
        draw_set_color(c_black);
        draw_ellipse(bubble_cx - bub_w, bubble_cy - bub_h,
                     bubble_cx + bub_w, bubble_cy + bub_h, true);
        draw_set_alpha(1);

        // Small divider line between the two items
        draw_set_alpha(thought_bubble_alpha * 0.4);
        draw_set_color(c_black);
        draw_line(bubble_cx, bubble_cy - bub_h + 6, bubble_cx, bubble_cy + bub_h - 6);
        draw_set_alpha(1);

        // Sprite 1 (main order) — left side
        if (order_sprite != noone) {
            // Grey out if already served
            var col1 = has_been_served ? c_gray : c_white;
            draw_sprite_ext(order_sprite, 0,
                bubble_cx - gap * 0.5, bubble_cy,
                spr_scale, spr_scale, 0, col1, thought_bubble_alpha);
        }

        // Sprite 2 (second order) — right side
        if (order_sprite2 != noone) {
            var col2 = has_been_served2 ? c_gray : c_white;
            draw_sprite_ext(order_sprite2, 0,
                bubble_cx + gap * 0.5, bubble_cy,
                spr_scale, spr_scale, 0, col2, thought_bubble_alpha);
        }

    } else {
        // === ORIGINAL SINGLE-ORDER BUBBLE ===
        var bubble_x      = x;
        var bubble_y      = y - 90;
        var bubble_radius = 50;

        draw_set_alpha(thought_bubble_alpha * 0.8);
        draw_set_color(bubble_color);
        draw_circle(bubble_x, bubble_y, bubble_radius, false);
        draw_set_color(c_black);
        draw_circle(bubble_x, bubble_y, bubble_radius, true);
        draw_set_alpha(1);

        if (order_sprite != noone) {
            draw_sprite_ext(order_sprite, 0, bubble_x, bubble_y,
                1.2, 1.2, 0, c_white, thought_bubble_alpha);
        }
    }
}

// Debug: Show state
/*
draw_set_color(c_white);
draw_text(x, y - 80, customer_state);
draw_text(x, y - 70, order_name);
*/