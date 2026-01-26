// === INVENTORY UI SETTINGS ===

// Box dimensions
box_width = 120;
box_height = 120;
box_padding = 10;

// Position offset from edge of screen
ui_margin_x = 90;
ui_margin_y = 50;

// Spacing between icon and inventory box
icon_spacing = 35;

// Icon scale
icon_scale = 0.85;

// Item sprite scale in the box
item_scale = 1.2;

// Hand-drawn effect settings
wobble_amount = 3;        // How much the lines wobble
corner_round = 8;         // Rounded corner size
line_segments = 12;       // Segments per side for wobble effect

// Box colors
box_color = c_black;
box_alpha = 0.7;
box_border_color = c_white;
box_border_width = 2;

// Function to get item display name from object type
function get_item_name(item) {
    if (item == noone || !instance_exists(item)) return "Empty";
    
    // Get object name and format it
    var obj_name = object_get_name(item.object_index);
    
    // Remove "OBJ_" prefix if present
    if (string_pos("OBJ_", obj_name) == 1) {
        obj_name = string_delete(obj_name, 1, 4);
    }
    
    // Add state info for food items
    if (variable_instance_exists(item, "food_type")) {
        switch (item.food_type) {
            case "raw": obj_name = "Raw " + obj_name; break;
            case "cooked": obj_name = "Cooked " + obj_name; break;
            case "burnt": obj_name = "Burnt " + obj_name; break;
        }
    }
    
    // For vegetables with state
    if (variable_instance_exists(item, "veggie_state")) {
        if (item.veggie_state == "sliced") {
            obj_name = "Sliced " + obj_name;
        }
    }
    
    return obj_name;
}
