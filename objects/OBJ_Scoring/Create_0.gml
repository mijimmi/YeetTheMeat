
// === SCORE ===
total_score = 0;
orders_completed = 0;
orders_failed = 0;

// === POINT VALUES (ADJUSTABLE HERE) ===
points_easy = 10;      
points_medium = 20;    
points_hard = 30;      
points_penalty = -5;   

// === RESULTS SCREEN ===
show_results = false;  // ADD THIS LINE

// === SCORE UI ANIMATION ===
score_pulse = 0;       // For pulsing animation
score_scale = 1;       // Current scale for animation

// ... rest of your functions stay the same ...
// === FOOD TYPE TO POINTS MAPPING ===
function get_food_points(food_type) {
    switch (food_type) {
        // Easy foods (+10)
        case "cooked":              // Generic cooked (rice, kwek-kwek)
            return points_easy;
        case "gulaman":
        case "buko":
            return points_easy;
            
        // Medium foods (+20)
        case "cooked_meat_lumpia":
        case "cooked_veggie_lumpia":
        case "adobo":
            return points_medium;
            
        // Hard foods (+30)
        case "caldereta":
            return points_hard;
            
        default:
            return 0;
    }
}

// === SPRITE TO POINTS MAPPING (for plated dishes) ===
function get_food_points_by_sprite(spr) {
    // Easy dishes
    if (spr == spr_ricedish || spr == spr_takoyakidish) {
        return points_easy;
    }
    // Medium dishes
    else if (spr == spr_meatlumpiadish || spr == spr_veggielumpiadish || spr == spr_adobodish) {
        return points_medium;
    }
    // Hard dishes
    else if (spr == spr_calderetadish) {
        return points_hard;
    }
    // Drinks
    else if (spr == spr_gulaman || spr == spr_bukojuice) {
        return points_easy;
    }
    
    return 0; // Unknown sprite
}

function add_score(points) {
    total_score += points;
    if (points > 0) {
        orders_completed++;
        score_scale = 1.3; // Pulse animation when score increases
    } else if (points < 0) {
        orders_failed++;
    }
}