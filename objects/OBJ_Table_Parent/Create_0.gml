// === TABLE CONFIGURATION ===
table_id = 0;              // Unique table number (set in children)
chair_count = 2;           // Number of chairs (2 or 4, set in children)
is_occupied = false;       // Is table currently occupied
current_group = noone;     // Reference to the group using this table

// === CHAIR POSITIONS ===
// Children will set these - positions relative to table center
chair_positions = [];      // Array of [x, y] positions for each chair

// === CUSTOMER REFERENCES ===
customers_at_table = [];   // Array of customer instances sitting here

// === VISUAL ===
highlight_alpha = 0;