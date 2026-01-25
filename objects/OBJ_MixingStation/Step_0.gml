event_inherited();

// Clean up destroyed ingredients
if (ingredient1 != noone && !instance_exists(ingredient1)) {
    ingredient1 = noone;
}
if (ingredient2 != noone && !instance_exists(ingredient2)) {
    ingredient2 = noone;
}