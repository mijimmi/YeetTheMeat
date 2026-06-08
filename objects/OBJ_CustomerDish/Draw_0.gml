// Draw the owner's table dish(es) using the layout the customer computed this
// frame. Self-destruct if the owner is gone or no longer showing dishes.
if (owner == noone || !instance_exists(owner) || !owner.dishUI_show) {
    instance_destroy();
    exit;
}

var o = owner;

var has1 = (o.dishUI_s1 != noone);
var has2 = (o.dishUI_s2 != noone);

if (has1) draw_sprite_ext(o.dishUI_s1, 0, o.dishUI_d1x, o.dishUI_d1y, o.dishUI_scale, o.dishUI_scale, 0, c_white, 1);
if (has2) draw_sprite_ext(o.dishUI_s2, 0, o.dishUI_d2x, o.dishUI_d2y, o.dishUI_scale, o.dishUI_scale, 0, c_white, 1);

// Eating cloud puffs over each present dish (slicing-style, no popcorn)
if (o.dishUI_eating) {
    var cloud_sprites = [spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4];
    var tf = current_time * 0.003;
    for (var s = 0; s < 2; s++) {
        if (s == 0 && !has1) continue;
        if (s == 1 && !has2) continue;
        var cxp = (s == 0) ? o.dishUI_d1x : o.dishUI_d2x;
        var cyp = (s == 0) ? o.dishUI_d1y : o.dishUI_d2y;
        for (var ci = 0; ci < 4; ci++) {
            var cspr = cloud_sprites[ci];
            var aoff = ci * 90;
            var cd   = 8 + sin(tf + ci * 1.5) * 4;
            var clx  = cxp + lengthdir_x(cd, tf * 60 + aoff);
            var cly  = cyp + lengthdir_y(cd * 0.6, tf * 60 + aoff) - 4;
            var csc  = (o.dishUI_both ? 0.6 : 0.72) + sin(tf * 2 + ci) * 0.15;
            var cal  = 0.6 + sin(tf * 3 + ci * 0.5) * 0.2;
            var crot = sin(tf + ci) * 15;
            draw_sprite_ext(cspr, 0, clx, cly, csc, csc, crot, c_white, cal);
        }
    }
}
