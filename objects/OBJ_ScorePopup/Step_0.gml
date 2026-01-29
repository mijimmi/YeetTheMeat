// Move upward
y += velocity_y;

// Grow scale
if (scale < scale_target) {
    scale += scale_speed;
}

// Fade out after half lifetime
lifetime++;
if (lifetime > max_lifetime / 2) {
    alpha -= fade_speed;
}

// Destroy when fully faded
if (alpha <= 0 || lifetime >= max_lifetime) {
    instance_destroy();
}
