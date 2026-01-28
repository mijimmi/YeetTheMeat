// Draw confetti particle as a rotated rectangle
draw_set_alpha(alpha);
draw_set_color(particle_color);

// Calculate rectangle corners based on rotation
var half_size = size / 2;
var corner1_x = x + lengthdir_x(half_size, rotation);
var corner1_y = y + lengthdir_y(half_size, rotation);
var corner2_x = x + lengthdir_x(half_size, rotation + 90);
var corner2_y = y + lengthdir_y(half_size, rotation + 90);
var corner3_x = x + lengthdir_x(half_size, rotation + 180);
var corner3_y = y + lengthdir_y(half_size, rotation + 180);
var corner4_x = x + lengthdir_x(half_size, rotation + 270);
var corner4_y = y + lengthdir_y(half_size, rotation + 270);

// Draw as a quad (rectangle)
draw_primitive_begin(pr_trianglestrip);
draw_vertex(corner1_x, corner1_y);
draw_vertex(corner2_x, corner2_y);
draw_vertex(corner4_x, corner4_y);
draw_vertex(corner3_x, corner3_y);
draw_primitive_end();

// Reset
draw_set_alpha(1);
draw_set_color(c_white);
