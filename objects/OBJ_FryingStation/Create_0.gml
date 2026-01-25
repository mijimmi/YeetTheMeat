event_inherited();

station_action = "Fry Food";
accepted_state = "";          // ← Changed! Accept ANY state (empty string)
output_state = "";            // ← Changed! Let food decide what it becomes
requires_cooking = true;

// Visual offset (optional, parent has defaults)
food_offset_x = 0;
food_offset_y = -20;

