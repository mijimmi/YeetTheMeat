// Check if food finished cooking and should be removed
if (food_on_station != noone && !instance_exists(food_on_station)) {
    food_on_station = noone;
}