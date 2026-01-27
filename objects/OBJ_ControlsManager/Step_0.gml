// Update closest station for each player (used by station Draw events for hints)

var p1 = instance_find(OBJ_P1, 0);
if (p1 != noone && instance_exists(p1)) {
    global.p1_closest_station = find_closest_station(p1.x, p1.y);
} else {
    global.p1_closest_station = noone;
}

var p2 = instance_find(OBJ_P2, 0);
if (p2 != noone && instance_exists(p2)) {
    global.p2_closest_station = find_closest_station(p2.x, p2.y);
} else {
    global.p2_closest_station = noone;
}
