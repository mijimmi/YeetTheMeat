// Check if player is close enough (short range - adjust the number as needed)
if (distance_to_object(OBJ_P1) < 24) {  // 24 pixels = very close range
    can_pickup = true;
    
    // Check for keyboard E or Xbox controller X button
    if (keyboard_check_pressed(ord("E")) || gamepad_button_check_pressed(0, gp_face3)) {
        // Pick up the item
        instance_destroy();
        
        // Optional: Play pickup sound
        // audio_play_sound(snd_pickup, 1, false);
        
        // Optional: Add to player inventory
        // OBJ_P1.item_count += 1;
    }
} else {
    can_pickup = false;
}