// Draw Event - Draw a cute paw-print indicator above the target station

if (current_phase == "recipe" && tutorial_target_station != noone && instance_exists(tutorial_target_station)) {
    var station = tutorial_target_station;

    // Position above the station, with a subtle bounce + pulse
    var paw_x = station.x;
    var paw_y = station.y - 52 + sin(arrow_bounce) * 3;
    var pulse = 1 + sin(arrow_bounce * 1.2) * 0.04;
    var paw_scale = 0.82;

    // Paw shape: one palm pad + four toe beans (dx, dy, rx, ry), relative to center
    var paw_parts = [
        [  0,  9, 15, 12],   // palm pad
        [-15, -5,  6,  7],   // far-left toe
        [ -6, -14, 6.5, 7.5],// mid-left toe
        [  6, -14, 6.5, 7.5],// mid-right toe
        [ 15, -5,  6,  7],   // far-right toe
    ];

    var paw_fill    = make_color_rgb(255, 188, 162); // slightly warmer peach than before
    var paw_outline = make_color_rgb(145, 78, 55);   // a touch lighter brown, still earthy
    var outline_pad = 3;
    var n = array_length(paw_parts);

    // Drop shadow (subtle)
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

    // Outline pass (slightly larger, brown)
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

    // Fill pass (peach)
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

    // Tiny highlight on the palm for a glossy, cute look
    draw_set_alpha(0.45);
    draw_set_color(make_color_rgb(255, 232, 215));
    var hl_rx = 4 * paw_scale * pulse;
    var hl_ry = 3 * paw_scale * pulse;
    draw_ellipse(paw_x - hl_rx - 2, paw_y + 4 * paw_scale - hl_ry, paw_x + hl_rx - 2, paw_y + 4 * paw_scale + hl_ry, false);

    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
}
