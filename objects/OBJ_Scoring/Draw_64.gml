// Draw GUI Event - This draws in screen space (follows camera automatically)

// Get camera properties for positioning
var cam = view_camera[0];
var cam_width = camera_get_view_width(cam);
var cam_height = camera_get_view_height(cam);

// HUD settings
var hud_x = 20;  // Left padding
var hud_y = 20;  // Top padding
var line_height = 30;

// Draw background panel (optional)
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_roundrect(hud_x - 10, hud_y - 10, hud_x + 300, hud_y + 130, false);
draw_set_alpha(1);

// Draw text
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);  // Use default font or set your own

// Score
draw_text(hud_x, hud_y, "Score: " + string(total_score));

// Orders completed
draw_text(hud_x, hud_y + line_height, "Orders Completed: " + string(orders_completed));

// Orders failed
draw_text(hud_x, hud_y + line_height * 2, "Orders Failed: " + string(orders_failed));

// Customer count
var active_customers = instance_number(OBJ_Customer);
draw_text(hud_x, hud_y + line_height * 3, "Customers: " + string(active_customers));

// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);