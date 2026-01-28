// === CUTSCENE CONTROLLER ===
// Plays intro cutscene before game starts

// Check if cutscene should play
if (!variable_global_exists("show_cutscene") || !global.show_cutscene) {
    instance_destroy();
    exit;
}

// Mark cutscene as shown (won't play again if restarting)
global.show_cutscene = false;

// Pause the game during cutscene
global.game_paused = true;

// === SCREEN SIZE ===
screen_width = display_get_gui_width();
screen_height = display_get_gui_height();
center_x = screen_width / 2;
center_y = screen_height / 2;

// === CUTSCENE STATE ===
// States: "left_enter", "middle_enter", "right_enter", "dialogue1", "dialogue2", "fade_out", "done"
cutscene_state = "left_enter";
state_timer = 0;

// === CHARACTER POSITIONS ===
// Left character - starts off screen left, moves to final position
left_x = -500;
left_y = center_y;
left_target_x = center_x;
left_target_y = center_y;
left_alpha = 1;

// Middle character - starts off screen bottom, moves up
middle_x = center_x;
middle_y = screen_height + 500;
middle_target_x = center_x;
middle_target_y = center_y;
middle_alpha = 0;

// Right character - starts off screen right, moves to final position
right_x = screen_width + 500;
right_y = center_y;
right_target_x = center_x;
right_target_y = center_y;
right_alpha = 0;

// === ANIMATION SETTINGS ===
move_speed = 0.04;  // Lerp speed for smooth movement

// === DIALOGUE ===
dialogue_lines = [
    "The road has gotten harder.",
    "There's nowhere to eat. Everything's too expensive."
];
current_line = 0;
dialogue_alpha = 0;
dialogue_y_offset = 0;

// === TEXT TYPING EFFECT ===
displayed_text = "";
full_text = "";
type_timer = 0;
type_speed = 2;  // Frames between each character
char_index = 0;
dialogue_started = false;

// === SKIP PROMPT ===
skip_alpha = 0.7;
skip_pulse_timer = 0;

// === FADE OUT ===
fade_alpha = 0;

// === INPUT ===
// Get gamepad if connected
gamepad = -1;
for (var i = 0; i < gamepad_get_device_count(); i++) {
    if (gamepad_is_connected(i)) {
        gamepad = i;
        break;
    }
}

// === BACKGROUND ===
bg_alpha = 1;  // Full black background - game not visible

// === SECOND CUTSCENE PART ===
silhouette_alpha = 0;
hunger_alpha = 0;
hunger_shake_intensity = 2;
hunger_shake_x = 0;
hunger_shake_y = 0;

// === THIRD CUTSCENE PART (SOYJACK) ===
soyjack_bg_alpha = 0;
soyjack_alpha = 0;
soyjack_y = screen_height + 500;  // Start below screen
soyjack_target_y = center_y + 100;
soyjack_shake_x = 0;
soyjack_shake_y = 0;
soyjack_shake_intensity = 3;

// === FOURTH CUTSCENE PART (FINAL DIALOGUE) ===
final_dialogue_bg_alpha = 0;
final_current_speaker = "";
final_dialogue_lines = [
    ["culay", "We can help! We've seen what they eat. How it's made."],
    ["culay", "Even something as small as this we can do!"],
    ["istar", "It's our turn now."],
    ["", "SERVE THE PEOPLE"]  // No speaker for final message
];
final_dialogue_index = 0;
final_dialogue_text_full = "";
final_dialogue_text_display = "";
final_dialogue_char_index = 0;
final_dialogue_type_timer = 0;
final_dialogue_type_speed = 2;
final_dialogue_text_complete = false;
final_istar_bob = 0;
final_culay_bob = 0;

// === FIFTH CUTSCENE PART (CHEER & SERVE THE PEOPLE LOGOS) ===
cheer_y = screen_height + 500;  // Start below screen
cheer_target_y = center_y;
cheer_alpha = 0;

servethepeople_y = -500;  // Start above screen
servethepeople_target_y = center_y;
servethepeople_alpha = 0;

press_key_alpha = 0;

// === LOADING SCREEN ===
loading_timer = 0;
loading_dot_count = 0;
loading_icon_bounce = 0;
loading_icon_rotation = 0;

// === DIALOGUE PART (ISTAR & CULAY) ===
dialogue_bg_alpha = 0;
current_speaker = ""; // "istar" or "culay"
dialogue_lines_full = [
    ["istar", "They're hungry. I know how that feels."],
    ["culay", "But they fed us."],
    ["istar", "On bad days. On hard times."],
    ["istar", "…What do we do?"],
    ["istar", "We're not much."],
    ["culay", "But we're here."],
    ["culay", "Wait a minute…"]
];
dialogue_index = 0;
dialogue_text = "";
dialogue_text_full = ""; // Full text to display
dialogue_text_display = ""; // Text being typed out
dialogue_char_index = 0;
dialogue_type_timer = 0;
dialogue_type_speed = 2;
dialogue_text_complete = false;
istar_bob = 0;
culay_bob = 0;
bob_speed = 0.1;
bob_amount = 8;

// Deactivate game objects during cutscene
instance_deactivate_object(OBJ_CustomerSpawner);
instance_deactivate_object(OBJ_Customer);
instance_deactivate_object(OBJ_P1);
instance_deactivate_object(OBJ_P2);
