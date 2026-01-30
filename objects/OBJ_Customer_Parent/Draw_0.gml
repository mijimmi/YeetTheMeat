// Draw customer sprite
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Draw thought bubble with order
if ((customer_state == "waiting" || customer_state == "leaving") && thought_bubble_alpha > 0) {
    // Bubble background (larger)
    var bubble_x = x;
    var bubble_y = y - 90;
    var bubble_radius = 50;
    
    // Calculate patience - how close to leaving (0 = just arrived, 1 = about to leave)
    var patience = min(wait_timer / max_wait_time, 1);
    
    // Interpolate bubble color from white to red based on patience
    var bubble_color = merge_color(c_white, make_color_rgb(255, 100, 100), patience);
    
    draw_set_alpha(thought_bubble_alpha * 0.8);
    draw_set_color(bubble_color);
    draw_circle(bubble_x, bubble_y, bubble_radius, false);
    draw_set_color(c_black);
    draw_circle(bubble_x, bubble_y, bubble_radius, true);
    draw_set_alpha(1);
    
    // Order sprite (bigger)
    if (order_sprite != noone) {
        draw_sprite_ext(order_sprite, 0, bubble_x, bubble_y, 1.2, 1.2, 0, c_white, thought_bubble_alpha);
    }
}

// Debug: Show state
/*
draw_set_color(c_white);
draw_text(x, y - 80, customer_state);
draw_text(x, y - 70, order_name);
*/