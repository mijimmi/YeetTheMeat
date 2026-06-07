// === DRAW HINT SPRITES ===
// Draw at depth below players, above background
// Sprites are 1920x1080 with middle-center origin, aligned to room

for (var i = 0; i < array_length(active_hints); i++) {
    var _entry   = active_hints[i];
    var hint_spr = _entry.spr;

    if (sprite_exists(hint_spr)) {
        var ox = sprite_get_xoffset(hint_spr);
        var oy = sprite_get_yoffset(hint_spr);
        draw_sprite(hint_spr, 0, ox, oy);
    }
}
