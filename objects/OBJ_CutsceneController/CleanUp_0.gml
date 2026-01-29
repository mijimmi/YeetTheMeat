// Reactivate all game objects when cutscene ends
instance_activate_all();

// Stop cutscene music
if (audio_is_playing(___Boy_and_Bag___watson)) {
    audio_stop_sound(___Boy_and_Bag___watson);
}