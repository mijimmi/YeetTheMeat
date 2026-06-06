// Station sprite is invisible - only show interaction hints

// Check P1 hint - only if this is P1's closest station
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && global.p1_closest_station == id) {
    var dist = point_distance(x, y, p1.x, p1.y);
    if (dist <= interact_range && p1.held_item != noone) {
        var hint_text = "X  Trash Item";
        var player_color = make_color_rgb(255, 100, 100);
        OBJ_ControlsManager.draw_action_prompt(x, y - 50, hint_text, p1, player_color);
    }
}

// Check P2 hint - only if this is P2's closest station
var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && global.p2_closest_station == id) {
    var dist = point_distance(x, y, p2.x, p2.y);
    if (dist <= interact_range && p2.held_item != noone) {
        var hint_text = "X  Trash Item";
        var player_color = make_color_rgb(220, 140, 40);
        var y_offset = -50;
        
        // Check if P1 also showing hint here
        if (p1 != noone && global.p1_closest_station == id && p1.held_item != noone) {
            y_offset = -78;
        }
        
        OBJ_ControlsManager.draw_action_prompt(x, y + y_offset, hint_text, p2, player_color);
    }
}
