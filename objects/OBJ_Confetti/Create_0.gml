// Confetti particle properties
velocity_x = random_range(-3, 3);
velocity_y = random_range(-8, -4);
gravity_force = 0.3;
rotation = random(360);
rotation_speed = random_range(-8, 8);

// Color (random bright colors)
var colors = [c_red, c_yellow, c_lime, c_aqua, c_fuchsia, c_orange];
particle_color = colors[irandom(array_length(colors) - 1)];

// Lifetime
alpha = 1;
fade_speed = 0.015;

// Size
size = random_range(3, 6);
