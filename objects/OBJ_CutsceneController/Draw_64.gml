// === DRAW CUTSCENE ON GUI LAYER ===

// Draw full black background (game not visible during cutscene)
draw_set_alpha(bg_alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, screen_width, screen_height, false);

// === DRAW CHARACTERS (FIRST PART) ===
// Only draw if not fully faded out and not in soyjack scenes
if (fade_alpha < 1 && cutscene_state != "soyjack_transition" && cutscene_state != "soyjack_show") {
    // Draw in order: left (back), middle, right (front)
    
    // Left character
    if (left_alpha > 0) {
        draw_set_alpha(left_alpha * (1 - fade_alpha));
        draw_sprite(spr_1left, 0, left_x, left_y);
    }
    
    // Middle character
    if (middle_alpha > 0) {
        draw_set_alpha(middle_alpha * (1 - fade_alpha));
        draw_sprite(spr_1middle, 0, middle_x, middle_y);
    }
    
    // Right character
    if (right_alpha > 0) {
        draw_set_alpha(right_alpha * (1 - fade_alpha));
        draw_sprite(spr_1right, 0, right_x, right_y);
    }
}

// === DRAW SECOND CUTSCENE PART ===
// Silhouette
if (silhouette_alpha > 0 && fade_alpha < 1 && cutscene_state != "soyjack_transition" && cutscene_state != "soyjack_show") {
    draw_set_alpha(silhouette_alpha * (1 - fade_alpha));
    draw_sprite(spr_2silhouette, 0, center_x, center_y);
}

// Hunger with shake
if (hunger_alpha > 0 && fade_alpha < 1 && cutscene_state != "soyjack_transition" && cutscene_state != "soyjack_show") {
    draw_set_alpha(hunger_alpha * (1 - fade_alpha));
    draw_sprite(spr_2hunger, 0, center_x + hunger_shake_x, center_y + hunger_shake_y);
}

// === DRAW DIALOGUE (NO BOX) ===
// Only show during first part of cutscene (not during other scenes)
if (displayed_text != "" && fade_alpha < 1 && 
    cutscene_state != "silhouette_show" && cutscene_state != "hunger_show" && 
    cutscene_state != "dialogue_transition" && cutscene_state != "dialogue_show" &&
    cutscene_state != "soyjack_transition" && cutscene_state != "soyjack_show") {
    draw_set_alpha(1 - fade_alpha);
    draw_set_color(c_white);
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Draw text with outline for readability - LARGER
    var text_x = center_x;
    var text_y = screen_height - 150;
    var text_scale = 3.0;
    
    // Draw black outline
    draw_set_color(c_black);
    var outline = 3;
    draw_text_transformed(text_x - outline, text_y, displayed_text, text_scale, text_scale, 0);
    draw_text_transformed(text_x + outline, text_y, displayed_text, text_scale, text_scale, 0);
    draw_text_transformed(text_x, text_y - outline, displayed_text, text_scale, text_scale, 0);
    draw_text_transformed(text_x, text_y + outline, displayed_text, text_scale, text_scale, 0);
    draw_text_transformed(text_x - outline, text_y - outline, displayed_text, text_scale, text_scale, 0);
    draw_text_transformed(text_x + outline, text_y - outline, displayed_text, text_scale, text_scale, 0);
    draw_text_transformed(text_x - outline, text_y + outline, displayed_text, text_scale, text_scale, 0);
    draw_text_transformed(text_x + outline, text_y + outline, displayed_text, text_scale, text_scale, 0);
    
    // Draw white text
    draw_set_color(c_white);
    draw_text_transformed(text_x, text_y, displayed_text, text_scale, text_scale, 0);
}

// === DRAW SKIP PROMPT ===
// Show throughout entire cutscene except final animation and fade out
if (cutscene_state != "done" && cutscene_state != "fade_out" && 
    cutscene_state != "final_animation_transition" && cutscene_state != "final_animation") {
    var pulse = 0.5 + sin(skip_pulse_timer) * 0.3;
    draw_set_alpha(pulse);
    draw_set_color(c_white);
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    // Slightly bigger text
    draw_text_transformed(center_x, screen_height - 40, "Press ENTER or START to skip", 1.3, 1.3, 0);
}

// === DRAW DIALOGUE SCENE ===
// Draw background during transition too (to fade it out)
if (dialogue_bg_alpha > 0 && fade_alpha < 1 && 
    (cutscene_state == "dialogue_show" || cutscene_state == "soyjack_transition")) {
    // Draw orange background
    draw_set_alpha(dialogue_bg_alpha * (1 - fade_alpha));
    draw_sprite(spr_orangebg, 0, center_x, center_y);
}

// Only draw dialogue content during dialogue_show state
if (cutscene_state == "dialogue_show" && dialogue_bg_alpha > 0 && fade_alpha < 1) {
    // Draw speech bubble (fullscreen 1920x1080)
    draw_set_alpha(1 - fade_alpha);
    if (current_speaker == "istar") {
        draw_sprite(spr_bubble_dog, 0, center_x, center_y);
    } else {
        draw_sprite(spr_cat_bubble, 0, center_x, center_y);
    }
    
    // Draw only the current speaker's icon (bigger and positioned higher)
    var icon_scale = 0.8;  // Bigger scale
    var icon_y = center_y + 50;  // Higher position
    
    if (current_speaker == "istar") {
        // Dog slightly toward right of center
        var bob_offset = sin(istar_bob) * bob_amount;
        draw_sprite_ext(spr_puppy_dialogue, 0, center_x - 150, icon_y + bob_offset, icon_scale, icon_scale, 0, c_white, 1 - fade_alpha);
    } else {
        // Cat slightly toward left of center
        var bob_offset = sin(culay_bob) * bob_amount;
        draw_sprite_ext(spr_kitty_dialogue, 0, center_x + 150, icon_y + bob_offset, icon_scale, icon_scale, 0, c_white, 1 - fade_alpha);
    }
    
    // Draw name at top left (ALL CAPS, BLACK) - moved right and closer to dialogue
    draw_set_alpha(1 - fade_alpha);
    draw_set_color(c_black);
    draw_set_font(global.game_font);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    var name_text = (current_speaker == "istar") ? "ISTAR" : "CULAY";
    draw_text_transformed(250, 120, name_text, 3.0, 3.0, 0);
    
    // Draw dialogue text with outline (WHITE with BLACK outline) - closer to name
    var text_x = center_x;
    var text_y = 180;  // Closer to name
    var text_scale = 3.0;
    var outline = 3;
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    
    // Draw black outline
    draw_set_color(c_black);
    draw_text_transformed(text_x - outline, text_y, dialogue_text_display, text_scale, text_scale, 0);
    draw_text_transformed(text_x + outline, text_y, dialogue_text_display, text_scale, text_scale, 0);
    draw_text_transformed(text_x, text_y - outline, dialogue_text_display, text_scale, text_scale, 0);
    draw_text_transformed(text_x, text_y + outline, dialogue_text_display, text_scale, text_scale, 0);
    draw_text_transformed(text_x - outline, text_y - outline, dialogue_text_display, text_scale, text_scale, 0);
    draw_text_transformed(text_x + outline, text_y - outline, dialogue_text_display, text_scale, text_scale, 0);
    draw_text_transformed(text_x - outline, text_y + outline, dialogue_text_display, text_scale, text_scale, 0);
    draw_text_transformed(text_x + outline, text_y + outline, dialogue_text_display, text_scale, text_scale, 0);
    
    // Draw white text on top
    draw_set_color(c_white);
    draw_text_transformed(text_x, text_y, dialogue_text_display, text_scale, text_scale, 0);
    
    // Draw small "A for next line" prompt below dialogue (only when text is complete) - BLACK
    if (dialogue_text_complete) {
        var pulse = 0.6 + sin(skip_pulse_timer * 1.5) * 0.4;
        draw_set_alpha(pulse);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(c_black);
        draw_text_transformed(center_x, text_y + 120, "A for next line", 1.0, 1.0, 0);
    }
}

// === DRAW SOYJACK SCENE ===
if (soyjack_bg_alpha > 0 && fade_alpha < 1 && 
    (cutscene_state == "soyjack_show" || cutscene_state == "final_dialogue_transition")) {
    // Draw background
    draw_set_alpha(soyjack_bg_alpha * (1 - fade_alpha));
    draw_sprite(spr_noorangebg, 0, center_x, center_y);
    
    // Draw soyjack with shake
    if (soyjack_alpha > 0) {
        draw_set_alpha(soyjack_alpha * (1 - fade_alpha));
        draw_sprite(spr_soyjack, 0, center_x + soyjack_shake_x, soyjack_y + soyjack_shake_y);
    }
}

// === DRAW FINAL DIALOGUE SCENE ===
if (final_dialogue_bg_alpha > 0 && fade_alpha < 1 && cutscene_state == "final_dialogue_show") {
    // Draw background
    draw_set_alpha(final_dialogue_bg_alpha * (1 - fade_alpha));
    draw_sprite(spr_noorangebg, 0, center_x, center_y);
    
    // Check if this is the final "SERVE THE PEOPLE" message (no speaker)
    if (final_current_speaker == "") {
        // Draw big centered text
        draw_set_alpha(1 - fade_alpha);
        draw_set_color(c_white);
        draw_set_font(global.game_font);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        var text_scale = 4.0;
        var outline = 4;
        
        // Draw black outline
        draw_set_color(c_black);
        draw_text_transformed(center_x - outline, center_y, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(center_x + outline, center_y, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(center_x, center_y - outline, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(center_x, center_y + outline, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(center_x - outline, center_y - outline, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(center_x + outline, center_y - outline, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(center_x - outline, center_y + outline, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(center_x + outline, center_y + outline, final_dialogue_text_display, text_scale, text_scale, 0);
        
        // Draw white text
        draw_set_color(c_white);
        draw_text_transformed(center_x, center_y, final_dialogue_text_display, text_scale, text_scale, 0);
    } else {
        // Draw speech bubble
        draw_set_alpha(1 - fade_alpha);
        if (final_current_speaker == "istar") {
            draw_sprite(spr_bubble_dog, 0, center_x, center_y);
        } else {
            draw_sprite(spr_cat_bubble, 0, center_x, center_y);
        }
        
        // Draw only the current speaker's icon
        var icon_scale = 0.8;
        var icon_y = center_y + 50;
        
        if (final_current_speaker == "istar") {
            var bob_offset = sin(final_istar_bob) * bob_amount;
            draw_sprite_ext(spr_puppy_dialogue, 0, center_x - 150, icon_y + bob_offset, icon_scale, icon_scale, 0, c_white, 1 - fade_alpha);
        } else {
            var bob_offset = sin(final_culay_bob) * bob_amount;
            draw_sprite_ext(spr_kitty_dialogue, 0, center_x + 150, icon_y + bob_offset, icon_scale, icon_scale, 0, c_white, 1 - fade_alpha);
        }
        
        // Draw name
        draw_set_alpha(1 - fade_alpha);
        draw_set_color(c_black);
        draw_set_font(global.game_font);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        var name_text = (final_current_speaker == "istar") ? "ISTAR" : "CULAY";
        draw_text_transformed(250, 120, name_text, 3.0, 3.0, 0);
        
        // Draw dialogue text with outline
        var text_x = center_x;
        var text_y = 180;
        var text_scale = 3.0;
        var outline = 3;
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        
        // Draw black outline
        draw_set_color(c_black);
        draw_text_transformed(text_x - outline, text_y, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(text_x + outline, text_y, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(text_x, text_y - outline, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(text_x, text_y + outline, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(text_x - outline, text_y - outline, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(text_x + outline, text_y - outline, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(text_x - outline, text_y + outline, final_dialogue_text_display, text_scale, text_scale, 0);
        draw_text_transformed(text_x + outline, text_y + outline, final_dialogue_text_display, text_scale, text_scale, 0);
        
        // Draw white text
        draw_set_color(c_white);
        draw_text_transformed(text_x, text_y, final_dialogue_text_display, text_scale, text_scale, 0);
        
        // Draw "A for next line" prompt
        if (final_dialogue_text_complete) {
            var pulse = 0.6 + sin(skip_pulse_timer * 1.5) * 0.4;
            draw_set_alpha(pulse);
            draw_set_halign(fa_center);
            draw_set_valign(fa_top);
            draw_set_color(c_black);
            draw_text_transformed(center_x, text_y + 120, "A for next line", 1.0, 1.0, 0);
        }
    }
}

// === DRAW FINAL ANIMATION (CHEER & SERVE THE PEOPLE) ===
if ((cutscene_state == "final_animation_transition" || cutscene_state == "final_animation") && fade_alpha < 1) {
    // Draw background
    draw_set_alpha(final_dialogue_bg_alpha * (1 - fade_alpha));
    draw_sprite(spr_noorangebg, 0, center_x, center_y);
    
    // Draw cheer sprite (coming from bottom)
    if (cheer_alpha > 0) {
        draw_set_alpha(cheer_alpha * (1 - fade_alpha));
        draw_sprite(spr_cheer, 0, center_x, cheer_y);
    }
    
    // Draw serve the people sprite (coming from top)
    if (servethepeople_alpha > 0) {
        draw_set_alpha(servethepeople_alpha * (1 - fade_alpha));
        draw_sprite(spr_servethepeople, 0, center_x, servethepeople_y);
    }
    
    // Draw "PRESS ANY KEY TO START GAME" prompt
    if (press_key_alpha > 0) {
        var pulse = 0.7 + sin(skip_pulse_timer * 1.2) * 0.3;
        draw_set_alpha(pulse * press_key_alpha * (1 - fade_alpha));
        draw_set_color(c_white);
        draw_set_font(global.game_font);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        
        var text_scale = 2.5;
        var outline = 4;
        
        // Draw black outline
        draw_set_color(c_black);
        draw_text_transformed(center_x - outline, screen_height - 100, "PRESS ANY KEY TO START GAME", text_scale, text_scale, 0);
        draw_text_transformed(center_x + outline, screen_height - 100, "PRESS ANY KEY TO START GAME", text_scale, text_scale, 0);
        draw_text_transformed(center_x, screen_height - 100 - outline, "PRESS ANY KEY TO START GAME", text_scale, text_scale, 0);
        draw_text_transformed(center_x, screen_height - 100 + outline, "PRESS ANY KEY TO START GAME", text_scale, text_scale, 0);
        
        // Draw white text
        draw_set_color(c_white);
        draw_text_transformed(center_x, screen_height - 100, "PRESS ANY KEY TO START GAME", text_scale, text_scale, 0);
    }
}

// === DRAW LOADING SCREEN ===
if (cutscene_state == "loading") {
    // Draw black background
    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_rectangle(0, 0, screen_width, screen_height, false);
    
    // Draw cute character icons bouncing
    var bounce_offset1 = sin(loading_icon_bounce) * 15;
    var bounce_offset2 = sin(loading_icon_bounce + 1.5) * 15;
    
    draw_set_alpha(1);
    // Draw P1 icon (left side, bouncing)
    draw_sprite_ext(spr_P1icon, 0, center_x - 150, center_y - 100 + bounce_offset1, 1.5, 1.5, sin(loading_icon_rotation * 0.05) * 10, c_white, 1);
    
    // Draw P2 icon (right side, bouncing)
    draw_sprite_ext(spr_P2icon, 0, center_x + 150, center_y - 100 + bounce_offset2, 1.5, 1.5, -sin(loading_icon_rotation * 0.05) * 10, c_white, 1);
    
    // Draw "Loading" text with animated dots
    draw_set_color(c_white);
    draw_set_font(global.game_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var dots = "";
    for (var i = 0; i < loading_dot_count; i++) {
        dots += ".";
    }
    
    var loading_text = "Loading" + dots;
    draw_text_transformed(center_x, center_y + 80, loading_text, 3.0, 3.0, 0);
    
    // Draw cute flavor text
    draw_set_alpha(0.8);
    draw_text_transformed(center_x, center_y + 150, "Preparing ingredients...", 1.5, 1.5, 0);
}

// === FADE OUT OVERLAY ===
if (fade_alpha > 0 && cutscene_state != "loading") {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, screen_width, screen_height, false);
}

// Reset draw settings
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
