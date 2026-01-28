// Update occupation status
if (array_length(customers_at_table) == 0) {
    is_occupied = false;
    current_group = noone;
}

// Fade highlight
if (is_occupied) {
    highlight_alpha = min(highlight_alpha + 0.05, 0.3);
} else {
    highlight_alpha = max(highlight_alpha - 0.05, 0);
}