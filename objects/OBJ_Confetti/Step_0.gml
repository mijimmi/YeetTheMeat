life++;

// Gravity + a little air drag
velocity_y += gravity_force;
velocity_x *= 0.99;

// Move (with horizontal flutter)
x += velocity_x + sin(sway_phase + life * sway_speed) * sway_amp;
y += velocity_y;

// Spin (slowing over time)
rotation += rotation_speed;
rotation_speed *= 0.99;

// Fade out late so the burst reads clearly
if (life > fade_delay) {
    alpha -= 0.045;
}

if (alpha <= 0 || life >= max_life) {
    instance_destroy();
}
