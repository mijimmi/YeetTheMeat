// Smooth scale animation
trash_scale = lerp(trash_scale, target_scale, 0.3);

// Reset scale after animation
if (trash_timer > 0) {
    trash_timer--;
    if (trash_timer <= 0) {
        target_scale = 1;
    }
}

// Clean up check (shouldn't be needed, but safety)
if (!instance_exists(id)) {
    return;
}

