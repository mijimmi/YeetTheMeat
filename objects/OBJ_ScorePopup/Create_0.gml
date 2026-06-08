// === SCORE POPUP ===
score_value  = 0;          // points to display
lifetime     = 0;
max_lifetime = 110;
alpha        = 1;

// Float upward, decelerating
vy = -3.0;

// Bouncy pop-in scale
scale      = 0.3;
base_scale = 2.1;          // bigger / more readable than before

// Twinkle phase for the sparkles
spark_phase = random(6.2832);

// Colour tiers (text + matching soft glow)
if (score_value >= 30) {
    text_color = make_color_rgb(255, 215,  0);   // gold (hard dishes)
    glow_color = make_color_rgb(255, 240, 170);
} else if (score_value >= 20) {
    text_color = make_color_rgb(255, 150,  40);  // orange (medium)
    glow_color = make_color_rgb(255, 205, 140);
} else if (score_value >= 10) {
    text_color = make_color_rgb(110, 255, 110);  // green (easy)
    glow_color = make_color_rgb(200, 255, 200);
} else {
    text_color = make_color_rgb(120, 220, 255);  // blue (small / drinks)
    glow_color = make_color_rgb(200, 240, 255);
}
