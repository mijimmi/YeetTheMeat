event_inherited();

// Override sprite based on initial state
switch (food_type) {
    case "raw":
        sprite_index = spr_rawkwek_kwek;
        break;
    case "cooked":
        sprite_index = spr_cookedkwek_kwek;
        break;
    case "burnt":
        sprite_index = spr_burnt;
        break;
}