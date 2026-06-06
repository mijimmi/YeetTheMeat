event_inherited();

stored_food = OBJ_Plate;  // Plates work as "food" for storage purposes
storage_name = "Plate";

// Instant plate: if the player walks up holding cooked food, hand them
// a fresh plate with the food already on it.
function interact_place(player) {
    if (spawn_cooldown > 0) return false;
    if (player.held_item == noone || !instance_exists(player.held_item)) return false;

    var food = player.held_item;

    // Only food objects can be plated here (not a plate that already holds food)
    if (!object_is_ancestor(food.object_index, OBJ_Food)) return false;

    var is_ready_to_plate = (
        food.food_type == "cooked" ||
        food.food_type == "fried_pork" ||
        food.food_type == "adobo" ||
        food.food_type == "cooked_meat_lumpia" ||
        food.food_type == "cooked_veggie_lumpia" ||
        food.food_type == "cooked_caldereta"
    );
    if (!is_ready_to_plate) return false;

    // Spawn a plate and combine the food onto it
    var plate = instance_create_depth(x, y, food.depth, OBJ_Plate);
    plate.food_on_plate = food;
    plate.has_food = true;

    food.is_held = false;
    food.held_by = noone;
    food.is_on_plate = true;
    food.plate_instance = plate;
    food.can_slide = false;

    // Player now holds the plated food
    plate.is_held = true;
    plate.held_by = player.id;
    player.held_item = plate;

    spawn_cooldown = spawn_cooldown_max;

    audio_sound_gain(sfx_item_pickup, 1.0, 0);
    audio_play_sound(sfx_item_pickup, 1, false);

    return true;
}