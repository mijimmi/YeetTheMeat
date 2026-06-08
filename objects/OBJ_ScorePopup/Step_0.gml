lifetime++;

// Pop in with a slight overshoot, then settle at base_scale
var pt = min(lifetime / 18, 1);
var overshoot = 1 + sin(pt * pi) * 0.30;          // bulge that returns to 1
scale = base_scale * lerp(0.35, 1, pt) * overshoot;

// Float upward, decelerating
y  += vy;
vy *= 0.93;

// Fade out in the last stretch
if (lifetime > max_lifetime * 0.55) {
    alpha -= 0.045;
}

if (alpha <= 0 || lifetime >= max_lifetime) {
    instance_destroy();
}
