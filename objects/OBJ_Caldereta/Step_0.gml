event_inherited();

// Custom cooking logic for Caldereta (cooks in Pot)
if (is_cooking && instance_exists(cooking_station)) {
    if (cooking_station.object_index == OBJ_PotStation) {
        // Raw caldereta -> Cooked
        if (food_type == "raw_caldereta" && cook_timer >= cook_time_required) {
            food_type = "cooked_caldereta";
            cook_timer = 0;
        }
        // Cooked -> Burnt
        else if (food_type == "cooked_caldereta" && cook_timer >= burn_time) {
            food_type = "burnt";
        }
    }
}

// Update sprite based on state
switch (food_type) {
    case "raw_caldereta":
        sprite_index = spr_rawcaldereta;
        plated_sprite = spr_calderetadish;
        break;
    case "cooked_caldereta":
        sprite_index = spr_cookedcaldereta;
        plated_sprite = spr_calderetadish;
        break;
    case "burnt":
        sprite_index = spr_burnt;
        plated_sprite = noone;
        break;
    case "plated":
        sprite_index = plated_sprite;
        break;
}

// Bobbing
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
