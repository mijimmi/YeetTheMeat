// Station sprite is invisible - only show interaction hints

// Does this player currently hold cooked food we can plate here?
function storage_can_plate(player_instance) {
    if (!variable_instance_exists(id, "interact_place")) return false;
    var item = player_instance.held_item;
    if (item == noone || !instance_exists(item)) return false;
    if (!object_is_ancestor(item.object_index, OBJ_Food)) return false;
    return (
        item.food_type == "cooked" ||
        item.food_type == "fried_pork" ||
        item.food_type == "adobo" ||
        item.food_type == "cooked_meat_lumpia" ||
        item.food_type == "cooked_veggie_lumpia" ||
        item.food_type == "cooked_caldereta"
    );
}

// Should we show any hint for this player?
function storage_show_hint(player_instance) {
    if (spawn_cooldown > 0) return false;
    return (player_instance.held_item == noone) || storage_can_plate(player_instance);
}

// Helper function to draw hint
function draw_storage_hint(player_instance, player_color, y_offset) {
    if (spawn_cooldown > 0) return;
    var hint_text;
    if (player_instance.held_item == noone) {
        hint_text = "X  Take " + storage_name;
    } else {
        hint_text = "X  Plate Food";
    }
    OBJ_ControlsManager.draw_action_prompt(x, y + y_offset, hint_text, player_instance, player_color);
}

// Check P1 hint - only if this is P1's closest station
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && global.p1_closest_station == id) {
    var dist = point_distance(x, y, p1.x, p1.y);
    if (dist <= interact_range && storage_show_hint(p1)) {
        draw_storage_hint(p1, make_color_rgb(255, 100, 100), -45);
    }
}

// Check P2 hint - only if this is P2's closest station
var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && global.p2_closest_station == id) {
    var dist = point_distance(x, y, p2.x, p2.y);
    if (dist <= interact_range && storage_show_hint(p2)) {
        var y_offset = -45;
        if (p1 != noone && global.p1_closest_station == id && storage_show_hint(p1)) {
            y_offset = -73; // Move P2 hint higher
        }
        draw_storage_hint(p2, make_color_rgb(220, 140, 40), y_offset);
    }
}
