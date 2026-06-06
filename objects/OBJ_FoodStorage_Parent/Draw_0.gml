// Station sprite is invisible - only show interaction hints

// Helper function to draw hint
function draw_storage_hint(player_instance, player_color, y_offset) {
    if (spawn_cooldown <= 0) {
        var hint_text = "X  Take " + storage_name;
        OBJ_ControlsManager.draw_action_prompt(x, y + y_offset, hint_text, player_instance, player_color);
    }
}

// Check P1 hint - only if this is P1's closest station
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && global.p1_closest_station == id) {
    var dist = point_distance(x, y, p1.x, p1.y);
    if (dist <= interact_range && p1.held_item == noone) {
        draw_storage_hint(p1, make_color_rgb(255, 100, 100), -45);
    }
}

// Check P2 hint - only if this is P2's closest station
var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && global.p2_closest_station == id) {
    var dist = point_distance(x, y, p2.x, p2.y);
    if (dist <= interact_range && p2.held_item == noone) {
        var y_offset = -45;
        if (p1 != noone && global.p1_closest_station == id && p1.held_item == noone) {
            y_offset = -73; // Move P2 hint higher
        }
        draw_storage_hint(p2, make_color_rgb(220, 140, 40), y_offset);
    }
}
