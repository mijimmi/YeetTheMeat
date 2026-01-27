// === PARENT FOR ALL FOOD STORAGES ===
interact_range = 85;
stored_food = noone;  // CHILD MUST SET THIS (e.g., OBJ_Meat, OBJ_Rice)

// Cooldown
spawn_cooldown = 0;
spawn_cooldown_max = 15;

// Display name for hints
storage_name = "Food";  // CHILD CAN OVERRIDE (e.g., "Meat", "Rice")

// === INTERACTION FUNCTION ===
function interact_take(player) {
    if (player.held_item == noone && spawn_cooldown <= 0) {
        var new_food = instance_create_depth(x, y, player.depth, stored_food);
        player.held_item = new_food;
        new_food.is_held = true;
        new_food.held_by = player.id;
        spawn_cooldown = spawn_cooldown_max;
        return true;
    }
    return false;
}