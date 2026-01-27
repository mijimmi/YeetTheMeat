// === DRAW HINT SPRITES ===
// Draw at depth below players, above background
// Sprites are 1920x1080 with middle-center origin, aligned to room

for (var i = 0; i < array_length(active_hints); i++) {
    var hint_spr = active_hints[i];
    
    if (sprite_exists(hint_spr)) {
        // Get sprite dimensions
        var spr_w = sprite_get_width(hint_spr);
        var spr_h = sprite_get_height(hint_spr);
        
        // Get sprite origin offset
        var ox = sprite_get_xoffset(hint_spr);
        var oy = sprite_get_yoffset(hint_spr);
        
        // Draw at room center (since sprites are middle-center aligned)
        // For 1920x1080 middle-center origin, draw at (960, 540) or use offset
        var draw_x = ox;  // If origin is middle-center, this puts it at 0,0 of room
        var draw_y = oy;
        
        draw_sprite(hint_spr, 0, draw_x, draw_y);
    }
}
