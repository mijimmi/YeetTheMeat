// === ROOM START: bake collision into the pathfinding grid ===
// Runs after EVERY instance in the room has been created, so all
// OBJ_CustomerCollision instances are guaranteed to exist (unlike the Create
// event, which can run before them in the room's instance creation order).
rebuild_grid();
