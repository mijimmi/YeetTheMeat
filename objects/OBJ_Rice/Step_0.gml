// Inherit parent's step event first
event_inherited();

switch (food_type) {
    case "raw":
        sprite_index = spr_rawrice;
        break;
    case "cooked":
        sprite_index = spr_cookedrice;
        break;
    case "burnt":
        sprite_index = spr_burnt;
        break;
    case "plated":
        sprite_index = plated_sprite; // Use the dish sprite
        break;
}

// Gentle bobbing animation when not held (from parent)
if (!is_held) {
    bob_timer += bob_speed;
}