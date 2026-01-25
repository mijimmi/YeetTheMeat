// === BUTTON MAPPINGS ===
global.btn_take = gp_face3;      // X - Take from stations
global.btn_place = gp_face1;     // A - Place items on stations
global.btn_drop = gp_face4;      // Y - Drop items anywhere

// Stations that support TAKE action
global.stations_take = [
    OBJ_KwekKwekStorage,
    OBJ_RiceDispenser,      
    OBJ_PlateStorage,
    OBJ_FryingStation,
    OBJ_PotStation,         
    OBJ_ServingCounter,
	OBJ_Freezer
];

// Stations that support PLACE action
global.stations_place = [
    OBJ_FryingStation,
    OBJ_PotStation,       
    OBJ_ServingCounter,
	OBJ_SlicingStation,
	OBJ_SoySauceStation
];
// === INTERACTION FUNCTIONS ===

function player_interact_take(player_instance) {
    // X BUTTON - TAKE FROM STATIONS
    var interacted = false;
    
    with (player_instance) {
        // Check all station types that support TAKE
        for (var i = 0; i < array_length(global.stations_take); i++) {
            if (interacted) break;
            
            var nearest_station = instance_nearest(x, y, global.stations_take[i]);
            if (nearest_station != noone && point_distance(x, y, nearest_station.x, nearest_station.y) <= nearest_station.interact_range) {
                if (variable_instance_exists(nearest_station, "interact_take")) {
                    interacted = nearest_station.interact_take(id);
                }
            }
        }
        
        // --- PICK UP FROM GROUND (FALLBACK) ---
        if (!interacted && held_item == noone) {
            var nearest_plate = instance_nearest(x, y, OBJ_Plate);
            if (nearest_plate != noone && !nearest_plate.is_held) {
                var dist = point_distance(x, y, nearest_plate.x, nearest_plate.y);
                if (dist <= interact_range) {
                    held_item = nearest_plate;
                    nearest_plate.is_held = true;
                    nearest_plate.held_by = id;
                    interacted = true;
                }
            }
            
            if (!interacted) {
                var nearest_food = instance_nearest(x, y, OBJ_Food);
                if (nearest_food != noone && !nearest_food.is_held && !nearest_food.is_cooking && !nearest_food.is_on_plate) {
                    var dist = point_distance(x, y, nearest_food.x, nearest_food.y);
                    if (dist <= interact_range) {
                        held_item = nearest_food;
                        nearest_food.is_held = true;
                        nearest_food.held_by = id;
                        interacted = true;
                    }
                }
            }
        }
    }
    
    return interacted;
}

function player_interact_place(player_instance) {
    // A BUTTON - PLACE ON STATIONS
    var interacted = false;
    
    with (player_instance) {
        // Check all station types that support PLACE
        for (var i = 0; i < array_length(global.stations_place); i++) {
            if (interacted) break;
            
            var nearest_station = instance_nearest(x, y, global.stations_place[i]);
            if (nearest_station != noone && point_distance(x, y, nearest_station.x, nearest_station.y) <= nearest_station.interact_range) {
                if (variable_instance_exists(nearest_station, "interact_place")) {
                    interacted = nearest_station.interact_place(id);
                }
            }
        }
        
        // --- COMBINE PLATE + FOOD ON GROUND (FALLBACK) ---
        if (!interacted) {
            if (held_item != noone && instance_exists(held_item) && held_item.object_index == OBJ_Plate) {
                var plate = held_item;
                if (!plate.has_food) {
                    var nearest_food = instance_nearest(x, y, OBJ_Food);
                    if (nearest_food != noone && !nearest_food.is_held && !nearest_food.is_cooking) {
                        var dist = point_distance(x, y, nearest_food.x, nearest_food.y);
                        if (dist <= interact_range) {
                            plate.food_on_plate = nearest_food;
                            plate.has_food = true;
                            nearest_food.is_on_plate = true;
                            nearest_food.plate_instance = plate;
                            interacted = true;
                        }
                    }
                }
            }
            else if (held_item != noone && instance_exists(held_item) && object_is_ancestor(held_item.object_index, OBJ_Food)) {
                var food = held_item;
                var nearest_plate = instance_nearest(x, y, OBJ_Plate);
                if (nearest_plate != noone && !nearest_plate.is_held && !nearest_plate.has_food) {
                    var dist = point_distance(x, y, nearest_plate.x, nearest_plate.y);
                    if (dist <= interact_range) {
                        nearest_plate.food_on_plate = food;
                        nearest_plate.has_food = true;
                        food.is_held = false;
                        food.held_by = noone;
                        food.is_on_plate = true;
                        food.plate_instance = nearest_plate;
                        
                        held_item = nearest_plate;
                        nearest_plate.is_held = true;
                        nearest_plate.held_by = id;
                        interacted = true;
                    }
                }
            }
        }
    }
    
    return interacted;
}

function player_drop_item(player_instance) {
    // Y BUTTON - DROP ANYWHERE
    var dropped = false;
    
    with (player_instance) {
        if (held_item != noone && instance_exists(held_item)) {
            held_item.x = x;
            held_item.y = y + 40;
            held_item.is_held = false;
            held_item.held_by = noone;
            
            if (object_is_ancestor(held_item.object_index, OBJ_Food)) {
                held_item.velocity_x = velocity_x * 0.5;
                held_item.velocity_y = velocity_y * 0.5;
            }
            else if (held_item.object_index == OBJ_Plate) {
                held_item.velocity_x = velocity_x * 0.5;
                held_item.velocity_y = velocity_y * 0.5;
            }
            
            if (held_item.object_index == OBJ_Plate && held_item.has_food) {
                var food = held_item.food_on_plate;
                if (food != noone && instance_exists(food)) {
                    food.x = x;
                    food.y = y + 30;
                    food.velocity_x = velocity_x * 0.5;
                    food.velocity_y = velocity_y * 0.5;
                }
            }
            
            held_item = noone;
            dropped = true;
        }
    }
    
    return dropped;
}
