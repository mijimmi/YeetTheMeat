// Station sprite is invisible - only show interaction hints and progress bar

// === PROGRESS BAR (when processing) ===
if (is_processing) {
    var bar_x = x - bar_width / 2;
    var bar_y = y - 70;
    var progress_pct = progress_current / progress_max;
    
    // Wobble seed for hand-drawn effect
    var wobble_seed = floor(current_time * 0.002);
    random_set_seed(wobble_seed);
    
    // === HAND-DRAWN BAR BORDER ===
    draw_set_color(make_color_rgb(50, 40, 35));
    
    for (var stroke = 0; stroke < line_segments; stroke++) {
        var ox = random_range(-wobble_amount, wobble_amount);
        var oy = random_range(-wobble_amount, wobble_amount);
        // Left
        draw_line_width(bar_x + ox, bar_y + oy, bar_x + random_range(-1, 1), bar_y + bar_height + oy, 2);
        // Right
        draw_line_width(bar_x + bar_width + ox, bar_y + oy, bar_x + bar_width + random_range(-1, 1), bar_y + bar_height + oy, 2);
        // Top
        draw_line_width(bar_x + ox, bar_y + oy, bar_x + bar_width + ox, bar_y + random_range(-1, 1), 2);
        // Bottom
        draw_line_width(bar_x + ox, bar_y + bar_height + oy, bar_x + bar_width + ox, bar_y + bar_height + random_range(-1, 1), 2);
    }
    
    // === BAR BACKGROUND ===
    draw_set_color(make_color_rgb(240, 235, 220));
    draw_rectangle(bar_x + 2, bar_y + 2, bar_x + bar_width - 2, bar_y + bar_height - 2, false);
    
    // Hatching
    draw_set_color(make_color_rgb(200, 190, 170));
    draw_set_alpha(0.4);
    for (var hatch = bar_x + 4; hatch < bar_x + bar_width - 2; hatch += 6) {
        draw_line(hatch, bar_y + 3, hatch + 4, bar_y + bar_height - 3);
    }
    draw_set_alpha(1);
    
    // === FILL ===
    if (progress_pct > 0.02) {
        var fill_width = progress_pct * (bar_width - 8);
        var fill_left = bar_x + 4;
        var fill_right = fill_left + fill_width;
        
        // Draw fill with gradient strokes (brown tones for soy sauce)
        for (var fx = fill_left; fx < fill_right; fx += 3) {
            var fill_progress = (fx - fill_left) / (bar_width - 8);
            
            // Light brown to dark brown color
            var fill_color = merge_color(make_color_rgb(180, 140, 80), make_color_rgb(80, 50, 30), fill_progress);
            draw_set_color(fill_color);
            
            var stroke_wobble = sin(fx * 0.3) * 1.5;
            draw_line_width(
                fx,
                bar_y + 4 + stroke_wobble,
                fx + random_range(-1, 1),
                bar_y + bar_height - 4 + stroke_wobble * 0.5,
                3
            );
        }
        
        // Shine highlight
        draw_set_color(c_white);
        draw_set_alpha(0.5);
        draw_line_width(fill_left + 3, bar_y + 5, fill_left + 3, bar_y + bar_height - 5, 2);
        draw_set_alpha(1);
    }
    
    // === Draw "Saucing.." text BELOW bar ===
    draw_set_font(fnt_winkle);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    
    // Animated dots
    var dots = "";
    var dot_count = floor((current_time / 300) mod 4);
    for (var d = 0; d < dot_count; d++) dots += ".";
    var label_text = "Saucing" + dots;
    
    var text_y = bar_y + bar_height + 4;
    
    // Black outline
    draw_set_color(c_black);
    for (var ox = -2; ox <= 2; ox++) {
        for (var oy = -2; oy <= 2; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text(x + ox, text_y + oy, label_text);
            }
        }
    }
    // White text
    draw_set_color(c_white);
    draw_text(x, text_y, label_text);
    
    // === CLOUD FX COVERING FOOD (tinted brown for soy sauce) ===
    var food_x = x + food_offset_x;
    var food_y = y + food_offset_y;
    var cloud_sprites = [spr_Fx1, spr_Fx2, spr_Fx3, spr_Fx4];
    var time_factor = current_time * 0.003;
    var sauce_tint = make_color_rgb(180, 150, 120); // Light brownish tint
    
    // Draw multiple animated clouds over the food
    for (var i = 0; i < 4; i++) {
        var cloud_spr = cloud_sprites[i mod 4];
        var angle_offset = i * 90;
        var cloud_dist = 8 + sin(time_factor + i * 1.5) * 4;
        var cloud_x = food_x + lengthdir_x(cloud_dist, time_factor * 60 + angle_offset);
        var cloud_y = food_y + lengthdir_y(cloud_dist * 0.6, time_factor * 60 + angle_offset);
        var cloud_scale = 0.4 + sin(time_factor * 2 + i) * 0.1;
        var cloud_alpha = 0.7 + sin(time_factor * 3 + i * 0.5) * 0.2;
        var cloud_rot = sin(time_factor + i) * 15;
        
        draw_sprite_ext(cloud_spr, 0, cloud_x, cloud_y, cloud_scale, cloud_scale, cloud_rot, sauce_tint, cloud_alpha);
    }
    
    random_set_seed(current_time);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// === INTERACTION HINTS ===
// Check P1 hint - only if this is P1's closest station
var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && global.p1_closest_station == id && !is_processing) {
    var dist = point_distance(x, y, p1.x, p1.y);
    if (dist <= interact_range) {
        var hint_text = "";
        var player_color = make_color_rgb(255, 100, 100);
        
        // Player holding sliced meat, station empty
        if (p1.held_item != noone && food_on_station == noone) {
            var item = p1.held_item;
            if (item.object_index == OBJ_Meat && item.food_type == "sliced") {
                hint_text = "A  Add Soy Sauce";
            }
        }
        // Station has sauced meat, player empty-handed
        else if (food_on_station != noone && p1.held_item == noone && !is_processing) {
            hint_text = "X  Take Food";
        }
        
        if (hint_text != "") {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_black);
            for (var xx = -2; xx <= 2; xx++) {
                for (var yy = -2; yy <= 2; yy++) {
                    if (xx != 0 || yy != 0) {
                        draw_text(x + xx, y - 50 + yy, hint_text);
                    }
                }
            }
            draw_set_color(player_color);
            draw_text(x, y - 50, hint_text);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}

// Check P2 hint - only if this is P2's closest station
var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && global.p2_closest_station == id && !is_processing) {
    var dist = point_distance(x, y, p2.x, p2.y);
    if (dist <= interact_range) {
        var hint_text = "";
        var player_color = make_color_rgb(220, 140, 40);
        
        // Player holding sliced meat, station empty
        if (p2.held_item != noone && food_on_station == noone) {
            var item = p2.held_item;
            if (item.object_index == OBJ_Meat && item.food_type == "sliced") {
                hint_text = "A  Add Soy Sauce";
            }
        }
        // Station has sauced meat, player empty-handed
        else if (food_on_station != noone && p2.held_item == noone && !is_processing) {
            hint_text = "X  Take Food";
        }
        
        if (hint_text != "") {
            // Offset if P1 also showing hint
            var y_offset = -50;
            if (p1 != noone && global.p1_closest_station == id) {
                y_offset = -70;
            }
            
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_black);
            for (var xx = -2; xx <= 2; xx++) {
                for (var yy = -2; yy <= 2; yy++) {
                    if (xx != 0 || yy != 0) {
                        draw_text(x + xx, y + y_offset + yy, hint_text);
                    }
                }
            }
            draw_set_color(player_color);
            draw_text(x, y + y_offset, hint_text);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}
