// Draw the confetti piece with a subtle dark edge so it pops against any
// background. Streamers/squares are rotated quads; sparkles are circles.
draw_set_alpha(alpha);

var edge = merge_color(particle_color, c_black, 0.40);

if (shape == 2) {
    // Round sparkle
    var r = size * 0.55;
    draw_set_color(edge);
    draw_circle(x, y, r + 1.2, false);
    draw_set_color(particle_color);
    draw_circle(x, y, r, false);
} else {
    // Rotated rectangle / streamer
    var hw = size * 0.5 * aspect;
    var hh = size * 0.5;

    // Outline pass (slightly larger), then colored fill
    var pad = 1.4;
    var passes = 2;
    for (var p = 0; p < passes; p++) {
        var ew = (p == 0) ? hw + pad : hw;
        var eh = (p == 0) ? hh + pad : hh;
        draw_set_color((p == 0) ? edge : particle_color);

        var ax = lengthdir_x(ew, rotation),      ay = lengthdir_y(ew, rotation);
        var bx = lengthdir_x(eh, rotation + 90), by = lengthdir_y(eh, rotation + 90);

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex(x + ax + bx, y + ay + by);
        draw_vertex(x - ax + bx, y - ay + by);
        draw_vertex(x + ax - bx, y + ay - by);
        draw_vertex(x - ax - bx, y - ay - by);
        draw_primitive_end();
    }
}

draw_set_alpha(1);
draw_set_color(c_white);
