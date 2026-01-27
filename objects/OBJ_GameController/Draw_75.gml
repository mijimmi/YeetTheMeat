// Draw GUI End Event - Overlay Layer (drawn on top of everything)

// Draw the overlay stretched to fill the entire GUI
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

if (sprite_exists(spr_Overlay)) {
    var spr_w = sprite_get_width(spr_Overlay);
    var spr_h = sprite_get_height(spr_Overlay);
    
    // Scale to fit the screen
    var scale_x = gui_width / spr_w;
    var scale_y = gui_height / spr_h;
    
    // Draw with slightly lower opacity
    draw_sprite_ext(spr_Overlay, 0, 0, 0, scale_x, scale_y, 0, c_white, 0.7);
}
