// === GAME MODE (set by menu, default to multiplayer for testing) ===
if (!variable_global_exists("game_mode")) {
    global.game_mode = "multiplayer";
}

// Global pause state
global.game_paused = false;

// === CREATE CUTSCENE CONTROLLER ===
// This will check if cutscene should play and handle it
instance_create_depth(0, 0, -9999, OBJ_CutsceneController);

// Input buffer to prevent instant unpause
pause_buffer = 0;

// Font
global.game_font = fnt_winkle;

// === CONTROLLER CONNECTION TRACKING ===
// Both players support keyboard fallback
p1_connected = gamepad_is_connected(0);
p1_disconnected = false;
global.controller_disconnected = false;

// Animation for disconnect message
disconnect_pulse_timer = 0;

// === MUSIC SYSTEM ===
// Three songs alternate during gameplay
current_song = 0; // 0 = Magic Cooking, 1 = Thirst, 2 = Viento del sol
songs = [Magic_Cooking___watson, Thirst___watson, Viento_del_sol___watson];
song_names = ["Magic Cooking", "Thirst", "Viento del sol"];
song_artist = "watson";

// Start first song with fade-in
if (!audio_is_playing(songs[current_song])) {
    audio_play_sound(songs[current_song], 1, false); // Don't loop, we'll switch songs
    audio_sound_gain(songs[current_song], 0, 0); // Start at 0
    audio_sound_gain(songs[current_song], 0.12, 2000); // Fade to 12% over 2 seconds
}