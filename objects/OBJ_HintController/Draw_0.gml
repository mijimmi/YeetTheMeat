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

// === DISH TUTORIAL GUIDE: force-show the current step's station hint ===
// Highlights the station the player needs next, even when they're not nearby.
if (guide_active && !global.game_paused && guide_step < array_length(guide_steps)) {
    var g_spr = guide_steps[guide_step].hint;
    if (sprite_exists(g_spr)) {
        var gox = sprite_get_xoffset(g_spr);
        var goy = sprite_get_yoffset(g_spr);
        draw_sprite(g_spr, 0, gox, goy);
    }

    // Paw indicator is drawn in the GUI layer (Draw_64) so it can be clamped
    // to the visible screen even when the station is off-camera.
}
