// Draw customer sprite
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Draw thought bubble with order
if (customer_state == "waiting" && thought_bubble_alpha > 0) {
    // Bubble background
    var bubble_x = x;
    var bubble_y = y - 60;
    
    draw_set_alpha(thought_bubble_alpha * 0.8);
    draw_set_color(c_white);
    draw_circle(bubble_x, bubble_y, 25, false);
    draw_set_color(c_black);
    draw_circle(bubble_x, bubble_y, 25, true);
    draw_set_alpha(1);
    
    // Order sprite
    if (order_sprite != noone) {
        draw_sprite_ext(order_sprite, 0, bubble_x, bubble_y, 0.5, 0.5, 0, c_white, thought_bubble_alpha);
    }
}

// Debug: Show state
/*
draw_set_color(c_white);
draw_text(x, y - 80, customer_state);
draw_text(x, y - 70, order_name);
*/