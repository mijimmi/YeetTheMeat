// === HINT CONTROLLER ===
// Shows sprite hints when players are near interactable objects

// Hint detection range
hint_range = 100;

// Current hints to display (can show multiple if both players near different stations)
active_hints = [];

// Map stations/storages to their hint sprites
hint_map = ds_map_create();

// Cooking Stations
ds_map_add(hint_map, OBJ_FryingStation, spr_FryHint);
ds_map_add(hint_map, OBJ_PotStation, spr_PotHint);
ds_map_add(hint_map, OBJ_SlicingStation, spr_SliceHint);
ds_map_add(hint_map, OBJ_SoySauceStation, spr_SauceHint);
ds_map_add(hint_map, OBJ_MixingStation, spr_MixHint);

// Storage Objects
ds_map_add(hint_map, OBJ_Freezer, spr_FridgeHint);
ds_map_add(hint_map, OBJ_KwekKwekStorage, spr_KwekKwekHint);
ds_map_add(hint_map, OBJ_RiceDispenser, spr_RiceHint);
ds_map_add(hint_map, OBJ_PlateStorage, spr_PlateHint);
ds_map_add(hint_map, OBJ_VeggieStorage, spr_VegetableHint);
ds_map_add(hint_map, OBJ_WrapperStorage, spr_WrapperHint);

// ServingCounter hint removed - no hint for placing plates

// Depth is controlled by the layer this instance is placed on in the room editor
