// Score popup properties
score_value = 0;              // The points to display (e.g., 10, 20, 30)
velocity_y = -2;              // Float upward
alpha = 1;
fade_speed = 0.02;
lifetime = 0;
max_lifetime = 90;            // About 1.5 seconds

// Visual properties
scale = 1.5;                  // Start at 1.5x size
scale_target = 2;             // Grow to 2x size
scale_speed = 0.05;           // How fast to grow

// Color based on points value
if (score_value >= 30) {
    text_color = make_color_rgb(255, 215, 0); // Gold for hard dishes
} else if (score_value >= 20) {
    text_color = make_color_rgb(255, 140, 0); // Orange for medium dishes
} else {
    text_color = make_color_rgb(100, 255, 100); // Light green for easy dishes
}
