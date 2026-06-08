// === CONFETTI PARTICLE ===
// Bursts outward with an upward bias, flutters as it falls, and fades late so it
// stays visible for a satisfying pop.
var ang = random(360);
var spd = random_range(3.5, 9);
velocity_x = lengthdir_x(spd, ang);
velocity_y = lengthdir_y(spd, ang) - random_range(4, 8); // bias upward
gravity_force = random_range(0.22, 0.34);

rotation = random(360);
rotation_speed = random_range(-13, 13);

// Bright, varied palette (incl. white sparkles)
var colors = [
    make_color_rgb(255,  80,  90),  // red
    make_color_rgb(255, 205,  60),  // gold
    make_color_rgb(120, 230, 110),  // green
    make_color_rgb( 90, 200, 255),  // sky
    make_color_rgb(220, 120, 255),  // purple
    make_color_rgb(255, 150,  60),  // orange
    make_color_rgb(255, 255, 255)   // white sparkle
];
particle_color = colors[irandom(array_length(colors) - 1)];

// Lifetime / fade
alpha      = 1;
life       = 0;
max_life   = random_range(64, 96);
fade_delay = max_life * 0.55;

// Size + shape (0 = streamer, 1 = square, 2 = circle)
size   = random_range(6, 12);
shape  = irandom(2);
aspect = (shape == 0) ? random_range(1.8, 3.0) : 1;

// Horizontal flutter
sway_amp   = random_range(0.4, 1.4);
sway_speed = random_range(0.10, 0.26);
sway_phase = random(6.2832);
