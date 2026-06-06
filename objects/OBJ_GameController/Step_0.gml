// === CONTROLLER CONNECTION TRACKING ===
// P1 supports keyboard fallback, so never pause the game on disconnect
p1_connected = gamepad_is_connected(0);
p1_disconnected = false;
global.controller_disconnected = false;

// === MUSIC MANAGEMENT ===
// Check if results screen is showing
var results_showing = false;
if (instance_exists(OBJ_Scoring) && OBJ_Scoring.show_results) {
    results_showing = true;
}

// Only play music when NOT in cutscene, tutorial, or results screen
if (instance_exists(OBJ_CutsceneController) || instance_exists(OBJ_TutorialManager) || results_showing) {
    // Stop all game music
    if (audio_is_playing(Magic_Cooking___watson)) {
        audio_stop_sound(Magic_Cooking___watson);
    }
    if (audio_is_playing(Thirst___watson)) {
        audio_stop_sound(Thirst___watson);
    }
    if (audio_is_playing(Viento_del_sol___watson)) {
        audio_stop_sound(Viento_del_sol___watson);
    }
}
else {
    // Normal music management - check if current song finished and switch to next
    if (!audio_is_playing(songs[current_song])) {
        // Switch to next song with fade-in
        current_song = (current_song + 1) % array_length(songs);
        audio_play_sound(songs[current_song], 1, false);
        audio_sound_gain(songs[current_song], 0, 0); // Start at 0
        audio_sound_gain(songs[current_song], 0.12, 2000); // Fade to 12% over 2 seconds
    }
}