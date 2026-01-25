event_inherited(); 

// === CUSTOM COOKING LOGIC FOR MEAT
// Parent already handled cook_timer++, so we just check for state transitions
if (is_cooking && instance_exists(cooking_station)) {
    // Check which station we're on
    if (cooking_station.object_index == OBJ_FryingStation) {
        // On frying station: sliced → fried_pork
        if (food_type == "sliced" && cook_timer >= cook_time_required) {
            food_type = "fried_pork";
            cook_timer = 0; // Reset for burn timer
        }
        else if (food_type == "fried_pork" && cook_timer >= burn_time) {
            food_type = "burnt";
        }
    }
    else if (cooking_station.object_index == OBJ_PotStation) {
        // On pot station: soy_sliced → adobo
        if (food_type == "soy_sliced" && cook_timer >= cook_time_required) {
            food_type = "adobo";
            cook_timer = 0; // Reset for burn timer
        }
        else if (food_type == "adobo" && cook_timer >= burn_time) {
            food_type = "burnt";
        }
    }
}

// Update sprite based on state
switch (food_type) {
    case "raw":
        sprite_index = spr_rawmeat;
        plated_sprite = noone;
        break;
    case "sliced":
        sprite_index = spr_slicedmeat;
        plated_sprite = noone;
        break;
    case "fried_pork":
        sprite_index = spr_porkchop;
        plated_sprite = spr_porkchopdish;
        break;
    case "soy_sliced":
        sprite_index = spr_soyslicedmeat;
        plated_sprite = noone;
        break;
    case "adobo":
        sprite_index = spr_soyslicedmeat27;
        plated_sprite = spr_adobodish;
        break;
    case "burnt":
        sprite_index = spr_burnt;
        break;
    case "plated":
        sprite_index = plated_sprite;
        break;
}

// Bobbing animation
var current_speed = point_distance(0, 0, velocity_x, velocity_y);

var on_counter = false;
if (is_on_plate && plate_instance != noone && instance_exists(plate_instance)) {
    with (OBJ_ServingCounter) {
        if (plate_on_counter == other.plate_instance) {
            on_counter = true;
        }
    }
}

if (!is_held && !is_cooking && current_speed < 0.3 && !on_counter) {
    bob_timer += bob_speed;
}