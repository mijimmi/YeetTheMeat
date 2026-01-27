// === INVENTORY UI SETTINGS ===

// Box dimensions
box_width = 90;
box_height = 90;
box_padding = 8;

// Position offset from edge of screen
ui_margin_x = 70;
ui_margin_y = 40;

// Spacing between icon and inventory box
icon_spacing = 25;

// Icon scale
icon_scale = 0.65;

// Item sprite scale in the box
item_scale = 1.3;

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
    
    // Special case: Plate with food - show the dish name
    if (item.object_index == OBJ_Plate && variable_instance_exists(item, "has_food") && item.has_food) {
        if (variable_instance_exists(item, "food_on_plate") && item.food_on_plate != noone && instance_exists(item.food_on_plate)) {
            var food = item.food_on_plate;
            
            // Check the sprite to determine the actual dish name
            var food_spr = food.sprite_index;
            
            // Match dish sprite to dish name
            if (food_spr == spr_porkchopdish) return "Fried Pork";
            if (food_spr == spr_adobodish) return "Adobo";
            if (food_spr == spr_meatlumpiadish) return "Meat Lumpia";
            if (food_spr == spr_veggielumpiadish) return "Veggie Lumpia";
            if (food_spr == spr_ricedish) return "Rice";
            if (food_spr == spr_takoyakidish) return "Kwek Kwek";
            
            // Fallback: check plated_sprite if food_type is "plated"
            if (variable_instance_exists(food, "plated_sprite") && food.plated_sprite != noone) {
                var plated_spr = food.plated_sprite;
                if (plated_spr == spr_porkchopdish) return "Fried Pork";
                if (plated_spr == spr_adobodish) return "Adobo";
                if (plated_spr == spr_meatlumpiadish) return "Meat Lumpia";
                if (plated_spr == spr_veggielumpiadish) return "Veggie Lumpia";
                if (plated_spr == spr_ricedish) return "Rice";
                if (plated_spr == spr_takoyakidish) return "Kwek Kwek";
            }
            
            // Final fallback: use object name
            var food_name = object_get_name(food.object_index);
            if (string_pos("OBJ_", food_name) == 1) {
                food_name = string_delete(food_name, 1, 4);
            }
            return food_name;
        }
        return "Plated Dish";
    }
    
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
            case "sliced": obj_name = "Sliced " + obj_name; break;
            case "soy_sliced": obj_name = "Marinated " + obj_name; break;
            case "fried_pork": obj_name = "Fried Pork"; break;
            case "adobo": obj_name = "Adobo"; break;
            case "cooked_meat_lumpia": obj_name = "Meat Lumpia"; break;
            case "cooked_veggie_lumpia": obj_name = "Veggie Lumpia"; break;
            case "raw_meat_lumpia": obj_name = "Raw Meat Lumpia"; break;
            case "raw_veggie_lumpia": obj_name = "Raw Veggie Lumpia"; break;
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
