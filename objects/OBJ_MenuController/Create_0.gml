// === MENU CONTROLLER ===
// Menu state: "main", "mode_select", or "leaderboard"
menu_state = "main";

// === MAIN MENU ===
// Button selection (0 = Start, 1 = Leaderboard, 2 = Exit)
selected_button = 0;
total_buttons = 3;

// === MODE SELECT MENU ===
// 0 = Singleplayer, 1 = Multiplayer, 2 = Go Back
selected_mode = 0;
total_mode_buttons = 3;
mode_button_scales = [1, 1, 1];

// === LEADERBOARD ===
leaderboard_back_scale = 1;

// Load leaderboard from file (persistent storage)
leaderboard_entries = [];
var leaderboard_file = "leaderboard.sav";

if (file_exists(leaderboard_file)) {
    var file = file_text_open_read(leaderboard_file);
    while (!file_text_eof(file)) {
        var line = file_text_read_string(file);
        file_text_readln(file);
        
        // Parse "NAME,SCORE" format
        if (string_length(line) > 0) {
            var comma_pos = string_pos(",", line);
            if (comma_pos > 0) {
                var entry_name = string_copy(line, 1, comma_pos - 1);
                var entry_score = real(string_copy(line, comma_pos + 1, string_length(line) - comma_pos));
                array_push(leaderboard_entries, [entry_name, entry_score]);
            }
        }
    }
    file_text_close(file);
}

// If no entries loaded, start with empty leaderboard
if (array_length(leaderboard_entries) == 0) {
    // Empty leaderboard - players will fill it!
    leaderboard_entries = [];
}

// Check for pending leaderboard entry from game
if (variable_global_exists("pending_leaderboard_entry") && global.pending_leaderboard_entry != noone) {
    var entry = global.pending_leaderboard_entry;
    var entry_name = entry[0];
    var entry_score = entry[1];
    
    // Add new entry
    array_push(leaderboard_entries, [entry_name, entry_score]);
    
    // Sort by score (descending)
    array_sort(leaderboard_entries, function(a, b) {
        return b[1] - a[1];
    });
    
    // Keep only top 10
    if (array_length(leaderboard_entries) > 10) {
        array_resize(leaderboard_entries, 10);
    }
    
    // Save updated leaderboard to file
    var save_file = file_text_open_write(leaderboard_file);
    for (var i = 0; i < array_length(leaderboard_entries); i++) {
        file_text_write_string(save_file, leaderboard_entries[i][0] + "," + string(leaderboard_entries[i][1]));
        file_text_writeln(save_file);
    }
    file_text_close(save_file);
    
    // Clear the pending entry
    global.pending_leaderboard_entry = noone;
}

// Global game mode (will be checked by game_room)
global.game_mode = "singleplayer";

// Global tutorial flag (NEW)
global.show_tutorial = true;  // Show tutorial before game

// Title animation (fluid multi-layered motion)
title_time = 0;

// Primary float (slow, smooth up/down)
title_float_speed = 0.015;
title_float_amount = 6;

// Secondary bob (faster, smaller - adds life)
title_bob_speed = 0.04;
title_bob_amount = 2;

// Gentle sway rotation
title_sway_speed = 0.012;
title_sway_amount = 2;

// Subtle breathing scale
title_breathe_speed = 0.018;
title_breathe_amount = 0.015;  // 1.5% scale variation

// Slight horizontal drift
title_drift_speed = 0.01;
title_drift_amount = 4;

// Button outline settings
outline_thickness = 6;
outline_color = c_orange;

// Button pop animation
button_scales = [1, 1, 1];        // Current scale for each button
button_target_scale = 1.15;       // Scale when highlighted (main menu - bigger)
button_normal_scale = 1.0;        // Scale when not highlighted
button_scale_speed = 0.15;        // How fast to animate

// Input cooldown to prevent rapid selection
input_cooldown = 0;
input_delay = 10; // frames

// Get gamepad if connected
gamepad = -1;
for (var i = 0; i < gamepad_get_device_count(); i++) {
    if (gamepad_is_connected(i)) {
        gamepad = i;
        break;
    }
}

// Track previous button selection for hover sound
previous_button = selected_button;
previous_mode = selected_mode;

// === MUSIC ===
// Play menu music (loop)
if (!audio_is_playing(____BGM_Pops_up_the_mind_wings_MusMus___BLPj3Fh9n1w_)) {
    audio_play_sound(____BGM_Pops_up_the_mind_wings_MusMus___BLPj3Fh9n1w_, 1, true);
    audio_sound_gain(____BGM_Pops_up_the_mind_wings_MusMus___BLPj3Fh9n1w_, 0.25, 0); 
}

// Music info for display
song_title = "Pop up the wind wings";
song_artist = "watson";

// Fade out control
is_fading_out = false;
fade_out_speed = 0.02; // Fade out over ~1.5 seconds