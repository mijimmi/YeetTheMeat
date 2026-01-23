// Inherit parent's step event first
event_inherited();

// Update sprite based on cooking state
if (sprite_index == -1 || (food_type == "raw" && sprite_index != spr_rawkwek_kwek) || 
    (food_type == "cooked" && sprite_index != spr_cookedkwek_kwek) || 
    (food_type == "burnt" && sprite_index != spr_burnt)) {
    
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
}