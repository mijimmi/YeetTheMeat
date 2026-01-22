// === DRAW CLOUD TRAIL ===
var dust_color = make_color_rgb(180, 150, 120);  // Dusty brown

for (var i = 0; i < ds_list_size(cloud_list); i++) {
    var cloud = cloud_list[| i];
    var cx = cloud[0];
    var cy = cloud[1];
    var cscale = cloud[2];
    var calpha = cloud[3];
    
    draw_set_alpha(calpha * 0.8);
    draw_set_color(dust_color);
    draw_circle(cx, cy, 6 * cscale, false);
    
    // Smaller puffs for fluffier look
    draw_set_alpha(calpha * 0.5);
    draw_circle(cx - 3 * cscale, cy - 2 * cscale, 4 * cscale, false);
    draw_circle(cx + 4 * cscale, cy - 1 * cscale, 3 * cscale, false);
}
draw_set_alpha(1);
draw_set_color(c_white);

// === AIMING UI ===
if (state == "aiming") {
    
    var arrow_length = aim_power * arrow_length_max;
    var power_color = merge_color(arrow_color_weak, arrow_color_strong, aim_power);
    
    var arrow_x = x + lengthdir_x(arrow_length, aim_dir);
    var arrow_y = y + lengthdir_y(arrow_length, aim_dir);
    
    // --- ARROW SPRITE (rotated) ---
    var arrow_scale = 1 + (aim_power * 0.5);
    draw_sprite_ext(spr_P1Arrow, 0, arrow_x, arrow_y, arrow_scale, arrow_scale, aim_dir - 90, power_color, 1);
    
  // --- POWER BAR (Hand-Drawn Style) ---
	var bar_x = x + 50;
	var bar_y = y - 50;
	var bar_width = 16;
	var bar_height = 58;

	// Wobble for hand-drawn feel
	var wobble_seed = floor(current_time * 0.002);
	random_set_seed(wobble_seed);

	// === SKETCHY OUTLINE (multiple strokes) ===
	draw_set_color(make_color_rgb(50, 40, 35));

	// Draw multiple wobbly lines for sketchy border
	for (var stroke = 0; stroke < 3; stroke++) {
	    var ox = random_range(-1, 1);
	    var oy = random_range(-1, 1);
    
	    // Left edge
	    draw_line_width(bar_x + ox, bar_y + oy, bar_x + random_range(-1, 1), bar_y + bar_height + oy, 2);
	    // Right edge
	    draw_line_width(bar_x + bar_width + ox, bar_y + oy, bar_x + bar_width + random_range(-1, 1), bar_y + bar_height + oy, 2);
	    // Top edge
	    draw_line_width(bar_x + ox, bar_y + oy, bar_x + bar_width + ox, bar_y + random_range(-1, 1), 2);
	    // Bottom edge
	    draw_line_width(bar_x + ox, bar_y + bar_height + oy, bar_x + bar_width + ox, bar_y + bar_height + random_range(-1, 1), 2);
}

// === INNER FILL BACKGROUND (scratchy) ===
draw_set_color(make_color_rgb(240, 235, 220));  // Paper/cream color
draw_rectangle(bar_x + 2, bar_y + 2, bar_x + bar_width - 2, bar_y + bar_height - 2, false);

// Cross-hatch shading on empty part
draw_set_color(make_color_rgb(200, 190, 170));
draw_set_alpha(0.4);
for (var hatch = bar_y + 4; hatch < bar_y + bar_height - 2; hatch += 4) {
    draw_line(bar_x + 3, hatch, bar_x + bar_width - 3, hatch + 3);
}
draw_set_alpha(1);

	// === POWER FILL (crayon/marker style) ===
	if (aim_power > 0.05) {
	    var fill_height = aim_power * (bar_height - 8);
	    var fill_bottom = bar_y + bar_height - 4;
	    var fill_top = fill_bottom - fill_height;
    
	    // Chunky fill strokes
	    for (var fy = fill_bottom; fy > fill_top; fy -= 3) {
	        var fill_progress = (fill_bottom - fy) / (bar_height - 8);
        
	        // Color: green to orange to red (marker colors)
	        var fill_color;
	        if (fill_progress < 0.5) {
	            fill_color = merge_color(make_color_rgb(100, 190, 80), make_color_rgb(230, 180, 50), fill_progress * 2);
	        } else {
	            fill_color = merge_color(make_color_rgb(230, 180, 50), make_color_rgb(210, 70, 60), (fill_progress - 0.5) * 2);
	        }
        
	        draw_set_color(fill_color);
        
	        // Wobbly horizontal strokes like marker
	        var stroke_wobble = sin(fy * 0.5) * 2;
	        draw_line_width(
	            bar_x + 4 + stroke_wobble,
	            fy,
	            bar_x + bar_width - 4 + stroke_wobble * 0.5,
	            fy + random_range(-1, 1),
	            3
	        );
	    }
    
	    // Highlight scribble
	    draw_set_color(c_white);
	    draw_set_alpha(0.5);
	    draw_line_width(bar_x + 5, fill_top + 5, bar_x + 6, fill_bottom - 5, 2);
	    draw_set_alpha(1);
	}

	// === DOODLE DECORATIONS ===
	draw_set_color(make_color_rgb(50, 40, 35));

	// Little arrows/marks on side
	draw_line_width(bar_x - 5, bar_y + bar_height, bar_x - 2, bar_y + bar_height, 1.5);
	draw_line_width(bar_x - 5, bar_y, bar_x - 2, bar_y, 1.5);

	// Small doodle marks at quarter points
	for (var m = 1; m < 4; m++) {
	    var mark_y = bar_y + (m * bar_height / 4);
	    draw_line(bar_x - 4, mark_y, bar_x - 1, mark_y);
	}

	// === MAX POWER SCRIBBLES ===
	if (aim_power >= 0.95) {
	    // Excited scribble lines around bar
	    draw_set_color(make_color_rgb(210, 70, 60));
	    var scrib_time = current_time * 0.008;
    
	    // Action lines
	    for (var line = 0; line < 5; line++) {
	        var angle = (line * 72) + sin(scrib_time + line) * 20;
	        var dist1 = 12 + sin(scrib_time * 2 + line) * 3;
	        var dist2 = 18 + sin(scrib_time * 3 + line) * 4;
	        var cx = bar_x + bar_width/2;
	        var cy = bar_y + 8;
        
	        draw_line_width(
	            cx + lengthdir_x(dist1, angle), cy + lengthdir_y(dist1, angle),
	            cx + lengthdir_x(dist2, angle), cy + lengthdir_y(dist2, angle),
	            1.5
	        );
	    }
    
	    // Little star scribble
	    draw_set_color(make_color_rgb(240, 200, 50));
	    var star_x = bar_x + bar_width + 8;
	    var star_y = bar_y + 5 + sin(scrib_time * 2) * 2;
	    draw_line_width(star_x - 4, star_y, star_x + 4, star_y, 2);
	    draw_line_width(star_x, star_y - 4, star_x, star_y + 4, 2);
	    draw_line_width(star_x - 3, star_y - 3, star_x + 3, star_y + 3, 1.5);
	    draw_line_width(star_x + 3, star_y - 3, star_x - 3, star_y + 3, 1.5);
	}

	// Reset random seed
	random_set_seed(current_time);
    
    
    // --- TRAJECTORY PREVIEW ---
    if (aim_power > 0.1) {
        var preview_speed = aim_power * aim_power_max;
        var px = x;
        var py = y;
        var pvx = lengthdir_x(preview_speed, aim_dir);
        var pvy = lengthdir_y(preview_speed, aim_dir);
        
        draw_set_color(c_white);
        for (var i = 0; i < 30; i++) {
            if (i mod 2 == 0) {
                draw_set_alpha(1 - (i / 35));
                draw_circle(px, py, 1, false);
            }
            px += pvx * 0.5;
            py += pvy * 0.5;
            pvx *= friction_rate;
            pvy *= friction_rate;
        }
        draw_set_alpha(1);
    }
    
// --- CANCEL HINT (Hand-Drawn Pastel Style) ---
	if (cancel_hint_alpha > 0) {
	    var hint_x = x;
	    var hint_y = y + 75;
	    var hint_text = "B";
    
	    // Subtle bounce animation
	    var hint_bounce = sin(current_time * 0.005) * 2;
	    hint_y += hint_bounce;
    
	    // Pastel colors
	    var pastel_pink = make_color_rgb(255, 180, 180);
	    var pastel_cream = make_color_rgb(255, 250, 240);
	    var sketch_brown = make_color_rgb(80, 60, 50);
    
	    // Wobble seed for hand-drawn feel
	    var hint_wobble_seed = floor(current_time * 0.003);
	    random_set_seed(hint_wobble_seed);
    
	    // Background shape (soft pastel fill)
	    var pill_width = 36;
	    var pill_height = 24;
    
	    draw_set_alpha(cancel_hint_alpha * 0.9);
	    draw_set_color(pastel_cream);
	    draw_roundrect(hint_x - pill_width/2, hint_y - pill_height/2, hint_x + pill_width/2, hint_y + pill_height/2, false);
    
	    // Sketchy border (multiple wobbly strokes)
	    draw_set_alpha(cancel_hint_alpha);
	    draw_set_color(sketch_brown);
	    for (var stroke = 0; stroke < 3; stroke++) {
	        var ox = random_range(-1, 1);
	        var oy = random_range(-1, 1);
	        draw_roundrect(
	            hint_x - pill_width/2 + ox, 
	            hint_y - pill_height/2 + oy, 
	            hint_x + pill_width/2 + ox, 
	            hint_y + pill_height/2 + oy, 
	            true
	        );
	    }
    
	    // Inner pastel accent circle
	    draw_set_alpha(cancel_hint_alpha * 0.6);
	    draw_set_color(pastel_pink);
	    draw_circle(hint_x, hint_y, 10, false);
    
	    // Sketchy circle border
	    draw_set_alpha(cancel_hint_alpha);
	    draw_set_color(sketch_brown);
	    for (var c = 0; c < 2; c++) {
	        draw_circle(hint_x + random_range(-0.5, 0.5), hint_y + random_range(-0.5, 0.5), 10, true);
	    }
    
	    // Hand-drawn "B" text
	    draw_set_alpha(cancel_hint_alpha);
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_middle);
	    draw_set_color(sketch_brown);
    
	    // Draw text with slight offset for hand-drawn feel
	    draw_text(hint_x + random_range(-0.5, 0.5), hint_y + random_range(-0.5, 0.5), hint_text);
    
	    // Little decorative dots/doodles
	    draw_set_alpha(cancel_hint_alpha * 0.7);
	    draw_set_color(pastel_pink);
	    draw_circle(hint_x - pill_width/2 - 6, hint_y - 2, 2, false);
	    draw_circle(hint_x + pill_width/2 + 6, hint_y + 2, 2, false);
    
	    // Tiny sparkle/star doodle
	    draw_set_color(sketch_brown);
	    draw_set_alpha(cancel_hint_alpha * 0.5);
	    var sparkle_x = hint_x + pill_width/2 + 4;
	    var sparkle_y = hint_y - pill_height/2 - 2;
	    draw_line_width(sparkle_x - 3, sparkle_y, sparkle_x + 3, sparkle_y, 1);
	    draw_line_width(sparkle_x, sparkle_y - 3, sparkle_x, sparkle_y + 3, 1);
    
	    // Reset
	    draw_set_halign(fa_left);
	    draw_set_valign(fa_top);
	    draw_set_alpha(1);
    
	    // Reset random seed
	    random_set_seed(current_time);
	}
}

// === RESET ===
draw_set_color(c_white);
draw_set_alpha(1);

// === DRAW HANDS ===
// Left hand - no flip (sprite points left by default)
draw_sprite_ext(spr_1Hand, hand_frame, x + hand1_x, y + hand1_y, hand_scale_x, hand_scale_y, hand1_angle, c_white, 1);
// Right hand - flip horizontally to point right
draw_sprite_ext(spr_1Hand, hand_frame, x + hand2_x, y + hand2_y, -hand_scale_x, hand_scale_y, hand2_angle, c_white, 1);

// === DRAW PLAYER BODY ===
var squish_threshold = 0.75;
var sprite_to_use = spr_P1;

if (state == "moving") {
    sprite_to_use = spr_P1Dash;
}
else if (scale_y < squish_threshold || (state == "aiming" && aim_power >= 0.85)) {
    sprite_to_use = spr_P1Squish;
}

draw_sprite_ext(
    sprite_to_use,
    facing_frame,
    x, y,
    scale_x * facing_flip,
    scale_y,
    0,
    c_white,
    1
);