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

    // === PAW INDICATOR above the target station (same as onboarding tutorial) ===
    var g_station_obj = guide_station_obj(g_spr);
    var g_station = (g_station_obj != noone) ? instance_find(g_station_obj, 0) : noone;
    if (g_station != noone && instance_exists(g_station)) {
        var paw_x = g_station.x;
        // Anchor above the actual sprite top so the paw always clears taller
        // stations (veggie storage, mixing/wrapper) instead of sinking into them.
        // Stations with a small placeholder mask get an extra lift so the paw
        // clears their (taller) painted art.
        var paw_top = min(g_station.y - 52, g_station.bbox_top - 20) - guide_paw_lift(g_station_obj);
        var paw_y = paw_top + sin(guide_arrow_bounce) * 3;
        var pulse = 1 + sin(guide_arrow_bounce * 1.2) * 0.04;
        var paw_scale = 0.82;

        var paw_parts = [
            [  0,  9, 15, 12],   // palm pad
            [-15, -5,  6,  7],   // far-left toe
            [ -6, -14, 6.5, 7.5],// mid-left toe
            [  6, -14, 6.5, 7.5],// mid-right toe
            [ 15, -5,  6,  7],   // far-right toe
        ];

        var paw_fill    = make_color_rgb(255, 188, 162);
        var paw_outline = make_color_rgb(145, 78, 55);
        var outline_pad = 3;
        var n = array_length(paw_parts);

        // Drop shadow
        draw_set_alpha(0.18);
        draw_set_color(c_black);
        for (var s = 0; s < n; s++) {
            var pdx = paw_parts[s][0] * paw_scale * pulse;
            var pdy = paw_parts[s][1] * paw_scale * pulse;
            var prx = paw_parts[s][2] * paw_scale * pulse;
            var pry = paw_parts[s][3] * paw_scale * pulse;
            draw_ellipse(paw_x + pdx - prx + 3, paw_y + pdy - pry + 5,
                         paw_x + pdx + prx + 3, paw_y + pdy + pry + 5, false);
        }

        // Outline
        draw_set_alpha(0.95);
        draw_set_color(paw_outline);
        for (var s = 0; s < n; s++) {
            var pdx = paw_parts[s][0] * paw_scale * pulse;
            var pdy = paw_parts[s][1] * paw_scale * pulse;
            var prx = paw_parts[s][2] * paw_scale * pulse + outline_pad;
            var pry = paw_parts[s][3] * paw_scale * pulse + outline_pad;
            draw_ellipse(paw_x + pdx - prx, paw_y + pdy - pry,
                         paw_x + pdx + prx, paw_y + pdy + pry, false);
        }

        // Fill
        draw_set_alpha(1);
        draw_set_color(paw_fill);
        for (var s = 0; s < n; s++) {
            var pdx = paw_parts[s][0] * paw_scale * pulse;
            var pdy = paw_parts[s][1] * paw_scale * pulse;
            var prx = paw_parts[s][2] * paw_scale * pulse;
            var pry = paw_parts[s][3] * paw_scale * pulse;
            draw_ellipse(paw_x + pdx - prx, paw_y + pdy - pry,
                         paw_x + pdx + prx, paw_y + pdy + pry, false);
        }

        // Glossy highlight
        draw_set_alpha(0.45);
        draw_set_color(make_color_rgb(255, 232, 215));
        var hl_rx = 4 * paw_scale * pulse;
        var hl_ry = 3 * paw_scale * pulse;
        draw_ellipse(paw_x - hl_rx - 2, paw_y + 4 * paw_scale - hl_ry, paw_x + hl_rx - 2, paw_y + 4 * paw_scale + hl_ry, false);

        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}
