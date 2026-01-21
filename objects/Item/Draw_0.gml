draw_self(); // Draw the item sprite

// Show interaction prompt when player is nearby
if (can_pickup) {
    draw_set_halign(fa_center);
    draw_text(x, y - 20, "Press E/X");
    draw_set_halign(fa_left);
}