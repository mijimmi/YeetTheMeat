// Step Event
var p1 = instance_find(OBJ_P1, 0);
var p2 = instance_find(OBJ_P2, 0);

if (p1 != noone && p2 != noone) {
    // Calculate midpoint between both players
    var mid_x = (p1.x + p2.x) / 2;
    var mid_y = (p1.y + p2.y) / 2;
    
    // Calculate distance between players
    var dist_x = abs(p1.x - p2.x);
    var dist_y = abs(p1.y - p2.y);
    
    // Calculate required zoom to fit both players
    var required_width = dist_x + padding * 2;
    var required_height = dist_y + padding * 2;
    
    // Prevent division by zero
    if (required_width < 1) required_width = 1;
    if (required_height < 1) required_height = 1;
    
    var zoom_x = base_width / required_width;
    var zoom_y = base_height / required_height;
    
    // Use the smaller zoom to ensure both players fit
    var target_zoom = min(zoom_x, zoom_y);
    
    // Clamp zoom between min and max
    target_zoom = clamp(target_zoom, min_zoom, max_zoom);
    
    // Smoothly interpolate to target zoom
    current_zoom = lerp(current_zoom, target_zoom, zoom_speed);
    
    // Calculate the view size based on zoom
    var view_w = base_width / current_zoom;
    var view_h = base_height / current_zoom;
    
    // Smoothly move camera to midpoint
    target_x = lerp(target_x, mid_x, cam_smooth);
    target_y = lerp(target_y, mid_y, cam_smooth);
    
    // Keep camera within room bounds
    target_x = clamp(target_x, view_w / 2, room_width - view_w / 2);
    target_y = clamp(target_y, view_h / 2, room_height - view_h / 2);
    
    // Apply camera position and size
    camera_set_view_size(cam, view_w, view_h);
    camera_set_view_pos(cam, target_x - view_w / 2, target_y - view_h / 2);
}
else if (p1 != noone) {
    // If only P1 exists, follow P1
    target_x = lerp(target_x, p1.x, cam_smooth);
    target_y = lerp(target_y, p1.y, cam_smooth);
    
    var view_w = base_width / current_zoom;
    var view_h = base_height / current_zoom;
    
    camera_set_view_pos(cam, target_x - view_w / 2, target_y - view_h / 2);
}
else if (p2 != noone) {
    // If only P2 exists, follow P2
    target_x = lerp(target_x, p2.x, cam_smooth);
    target_y = lerp(target_y, p2.y, cam_smooth);
    
    var view_w = base_width / current_zoom;
    var view_h = base_height / current_zoom;
    
    camera_set_view_pos(cam, target_x - view_w / 2, target_y - view_h / 2);
}