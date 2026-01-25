// Step Event
var p1 = instance_find(OBJ_P1, 0);
var p2 = instance_find(OBJ_P2, 0);

// === GET SHAKE FROM PLAYERS (COLLISIONS ONLY) ===
var max_shake = 0;
if (p1 != noone && variable_instance_exists(p1, "cam_shake")) {
    max_shake = max(max_shake, p1.cam_shake);
}
if (p2 != noone && variable_instance_exists(p2, "cam_shake")) {
    max_shake = max(max_shake, p2.cam_shake);
}

// Add to camera shake intensity
if (max_shake > shake_intensity) {
    shake_intensity = max_shake;
}

// Calculate shake offset
if (shake_intensity > 0.5) {
    shake_x = random_range(-shake_intensity, shake_intensity);
    shake_y = random_range(-shake_intensity, shake_intensity);
    shake_intensity *= shake_decay;
} else {
    shake_x = 0;
    shake_y = 0;
    shake_intensity = 0;
}

// Calculate view size (needed for all cases)
var view_w = base_width / current_zoom;
var view_h = base_height / current_zoom;

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
    
    if (required_width < 1) required_width = 1;
    if (required_height < 1) required_height = 1;
    
    var zoom_x = base_width / required_width;
    var zoom_y = base_height / required_height;
    
    var target_zoom = min(zoom_x, zoom_y);
    target_zoom = clamp(target_zoom, min_zoom, max_zoom);
    
    current_zoom = lerp(current_zoom, target_zoom, zoom_speed);
    
    view_w = base_width / current_zoom;
    view_h = base_height / current_zoom;
    
    target_x = lerp(target_x, mid_x, cam_smooth);
    target_y = lerp(target_y, mid_y, cam_smooth);
}
else if (p1 != noone) {
    // Single player - zoom to max and follow P1
    current_zoom = lerp(current_zoom, max_zoom, zoom_speed);
    
    view_w = base_width / current_zoom;
    view_h = base_height / current_zoom;
    
    target_x = lerp(target_x, p1.x, cam_smooth);
    target_y = lerp(target_y, p1.y, cam_smooth);
}
else if (p2 != noone) {
    // Single player - zoom to max and follow P2
    current_zoom = lerp(current_zoom, max_zoom, zoom_speed);
    
    view_w = base_width / current_zoom;
    view_h = base_height / current_zoom;
    
    target_x = lerp(target_x, p2.x, cam_smooth);
    target_y = lerp(target_y, p2.y, cam_smooth);
}

// Keep camera within room bounds (for ALL cases)
target_x = clamp(target_x, view_w / 2, room_width - view_w / 2);
target_y = clamp(target_y, view_h / 2, room_height - view_h / 2);

// Apply camera position and size with shake (for ALL cases)
camera_set_view_size(cam, view_w, view_h);
camera_set_view_pos(cam, target_x - view_w / 2 + shake_x, target_y - view_h / 2 + shake_y);