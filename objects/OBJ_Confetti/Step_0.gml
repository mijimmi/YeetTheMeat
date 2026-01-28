// Apply gravity
velocity_y += gravity_force;

// Move
x += velocity_x;
y += velocity_y;

// Rotate
rotation += rotation_speed;

// Fade out
alpha -= fade_speed;

// Destroy when fully faded
if (alpha <= 0) {
    instance_destroy();
}
