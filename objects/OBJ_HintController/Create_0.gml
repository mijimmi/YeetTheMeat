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
ds_map_add(hint_map, OBJ_CupStorage, spr_CupHint);

// Dispensers
ds_map_add(hint_map, OBJ_GulamanDispenser, spr_GulamanHint);
ds_map_add(hint_map, OBJ_BukoDispenser, spr_BukoHint);

// Trash
ds_map_add(hint_map, OBJ_TrashCan, spr_TrashHint);

// ServingCounter hint removed - no hint for placing plates

// Depth is controlled by the layer this instance is placed on in the room editor

// =====================================================================
// === DISH TUTORIAL GUIDE =============================================
// =====================================================================
// Driven by the recipe book: when a dish is chosen and the book closes,
// this walks the player through that dish using the station hint sprites,
// advancing one step at a time as each step is completed.

guide_active = false;
guide_dish   = "";
guide_name   = "";
guide_step   = 0;
guide_steps  = [];
guide_done_flash = 0;   // brief "Dish complete!" celebration timer
guide_arrow_bounce = 0; // paw indicator animation timer

// Maps a step's hint sprite back to the station object so the paw indicator
// can be drawn above it (mirrors the onboarding tutorial's paw).
function guide_station_obj(_hint) {
    if (_hint == spr_KwekKwekHint)  return OBJ_KwekKwekStorage;
    if (_hint == spr_FryHint)       return OBJ_FryingStation;
    if (_hint == spr_PlateHint)     return OBJ_PlateStorage;
    if (_hint == spr_FridgeHint)    return OBJ_Freezer;
    if (_hint == spr_SliceHint)     return OBJ_SlicingStation;
    if (_hint == spr_SauceHint)     return OBJ_SoySauceStation;
    if (_hint == spr_PotHint)       return OBJ_PotStation;
    if (_hint == spr_MixHint)       return OBJ_MixingStation;
    if (_hint == spr_WrapperHint)   return OBJ_WrapperStorage;
    if (_hint == spr_VegetableHint) return OBJ_VeggieStorage;
    if (_hint == spr_RiceHint)      return OBJ_RiceDispenser;
    return noone;
}

// Some stations (wrapper, veggie) use a small placeholder collision sprite while
// their painted kitchen art is much taller, so the paw computed from the mask
// sits too low. Return extra pixels to lift the paw for those tall stations.
function guide_paw_lift(_obj) {
    if (_obj == OBJ_WrapperStorage) return 64;
    if (_obj == OBJ_VeggieStorage)  return 64;
    return 0;
}

// --- Step constructors (each step = { hint sprite, label, completion rule }) ---
function gs_held(_h, _l, _o, _f)            { return { hint:_h, label:_l, kind:"held",    obj:_o, ft:_f }; }
function gs_exists(_h, _l, _o, _f)          { return { hint:_h, label:_l, kind:"exists",  obj:_o, ft:_f }; }
function gs_mix(_h, _l, _fo, _ff, _ro, _rf) { return { hint:_h, label:_l, kind:"mix",     obj:_fo, ft:_ff, res_obj:_ro, res_ft:_rf }; }
function gs_plated(_h, _l, _o, _f, _spr)    { return { hint:_h, label:_l, kind:"plated",  pl_obj:_o, pl_ft:_f, pl_spr:_spr }; }

// --- Completion probes ---
function guide_item_matches(_it, _obj, _ft) {
    if (_it == noone || !instance_exists(_it)) return false;
    if (_it.object_index != _obj) return false;
    if (_ft == "") return true;
    if (variable_instance_exists(_it, "food_type")   && _it.food_type   == _ft) return true;
    if (variable_instance_exists(_it, "veggie_state")&& _it.veggie_state == _ft) return true;
    if (variable_instance_exists(_it, "drink_type")  && _it.drink_type  == _ft) return true;
    return false;
}

function guide_held(_obj, _ft) {
    var p1 = instance_find(OBJ_P1, 0);
    var p2 = instance_find(OBJ_P2, 0);
    if (p1 != noone && instance_exists(p1) && guide_item_matches(p1.held_item, _obj, _ft)) return true;
    if (p2 != noone && instance_exists(p2) && guide_item_matches(p2.held_item, _obj, _ft)) return true;
    return false;
}

function guide_exists(_obj, _ft) {
    var r = false;
    with (_obj) {
        if (_ft == "") { r = true; break; }
        if (variable_instance_exists(id, "food_type")    && food_type    == _ft) { r = true; break; }
        if (variable_instance_exists(id, "veggie_state") && veggie_state == _ft) { r = true; break; }
    }
    return r;
}

function guide_mix(_fill_obj, _fill_ft, _res_obj, _res_ft) {
    // Done as soon as the mixed result exists...
    if (guide_exists(_res_obj, _res_ft)) return true;
    // ...or while the filling is already sitting in the mixing station.
    var s = instance_find(OBJ_MixingStation, 0);
    if (s == noone || !instance_exists(s)) return false;
    if (variable_instance_exists(s, "ingredient1") && guide_item_matches(s.ingredient1, _fill_obj, _fill_ft)) return true;
    if (variable_instance_exists(s, "ingredient2") && guide_item_matches(s.ingredient2, _fill_obj, _fill_ft)) return true;
    return false;
}

function guide_plated(_obj, _ft, _spr) {
    var r = false;
    with (OBJ_Plate) {
        if (has_food && food_on_plate != noone && instance_exists(food_on_plate)) {
            var f = food_on_plate;
            if (f.object_index == _obj) {
                if (variable_instance_exists(f, "food_type") && f.food_type == _ft) { r = true; break; }
                if (variable_instance_exists(f, "plated_sprite") && f.plated_sprite == _spr) { r = true; break; }
            }
        }
    }
    return r;
}

function evaluate_guide_step(_st) {
    switch (_st.kind) {
        case "held":   return guide_held(_st.obj, _st.ft);
        case "exists": return guide_exists(_st.obj, _st.ft);
        case "mix":    return guide_mix(_st.obj, _st.ft, _st.res_obj, _st.res_ft);
        case "plated": return guide_plated(_st.pl_obj, _st.pl_ft, _st.pl_spr);
    }
    return false;
}

function cancel_dish_guide() {
    guide_active = false;
    guide_dish   = "";
    guide_step   = 0;
    guide_steps  = [];
}

function start_dish_guide(_dish) {
    guide_steps = [];
    guide_dish  = _dish;
    guide_name  = "";
    guide_step  = 0;
    guide_active = false;

    switch (_dish) {
        case "kwekkwek":
            guide_name = "Kwek-Kwek";
            array_push(guide_steps, gs_held(  spr_KwekKwekHint, "Take a Kwek-Kwek from the container", OBJ_KwekKwek, ""));
            array_push(guide_steps, gs_exists(spr_FryHint,      "Fry it in a pan until orange",        OBJ_KwekKwek, "cooked"));
            array_push(guide_steps, gs_plated(spr_PlateHint,    "Serve it on a plate",                 OBJ_KwekKwek, "cooked", spr_takoyakidish));
            break;

        case "friedpork":
            guide_name = "Fried Pork";
            array_push(guide_steps, gs_held(  spr_FridgeHint, "Take meat from the freezer",   OBJ_Meat, "raw"));
            array_push(guide_steps, gs_exists(spr_SliceHint,  "Slice the meat",               OBJ_Meat, "sliced"));
            array_push(guide_steps, gs_exists(spr_FryHint,    "Fry the sliced meat in a pan", OBJ_Meat, "fried_pork"));
            array_push(guide_steps, gs_plated(spr_PlateHint,  "Serve it on a plate",          OBJ_Meat, "fried_pork", spr_porkchopdish));
            break;

        case "adobo":
            guide_name = "Adobo";
            array_push(guide_steps, gs_held(  spr_FridgeHint, "Take meat from the freezer",         OBJ_Meat, "raw"));
            array_push(guide_steps, gs_exists(spr_SliceHint,  "Slice the meat",                     OBJ_Meat, "sliced"));
            array_push(guide_steps, gs_exists(spr_SauceHint,  "Add sauce at the saucing station",   OBJ_Meat, "soy_sliced"));
            array_push(guide_steps, gs_exists(spr_PotHint,    "Cook it in the pot",                 OBJ_Meat, "adobo"));
            array_push(guide_steps, gs_plated(spr_PlateHint,  "Serve it on a plate",                OBJ_Meat, "adobo", spr_adobodish));
            break;

        case "rice":
            guide_name = "Rice";
            array_push(guide_steps, gs_held(  spr_RiceHint,  "Take rice from the rice sack", OBJ_Rice, "raw"));
            array_push(guide_steps, gs_exists(spr_PotHint,   "Cook it in the pot",           OBJ_Rice, "cooked"));
            array_push(guide_steps, gs_plated(spr_PlateHint, "Serve it on a plate",          OBJ_Rice, "cooked", spr_ricedish));
            break;

        case "meatlumpia":
            guide_name = "Meat Lumpia";
            array_push(guide_steps, gs_held(  spr_FridgeHint,  "Take meat from the freezer",          OBJ_Meat,   "raw"));
            array_push(guide_steps, gs_exists(spr_SliceHint,   "Slice the meat",                      OBJ_Meat,   "sliced"));
            array_push(guide_steps, gs_mix(   spr_MixHint,     "Put the sliced meat in the mixer",    OBJ_Meat,   "sliced", OBJ_Lumpia, "raw_meat_lumpia"));
            array_push(guide_steps, gs_exists(spr_WrapperHint, "Add a lumpia wrapper to the mixer",   OBJ_Lumpia, "raw_meat_lumpia"));
            array_push(guide_steps, gs_exists(spr_FryHint,     "Fry the lumpia in a pan",             OBJ_Lumpia, "cooked_meat_lumpia"));
            array_push(guide_steps, gs_plated(spr_PlateHint,   "Serve it on a plate",                 OBJ_Lumpia, "cooked_meat_lumpia", spr_meatlumpiadish));
            break;

        case "veggielumpia":
            guide_name = "Veggie Lumpia";
            array_push(guide_steps, gs_held(  spr_VegetableHint,"Take veggies from veggie storage",   OBJ_Vegetables, "raw"));
            array_push(guide_steps, gs_exists(spr_SliceHint,    "Slice the veggies",                  OBJ_Vegetables, "sliced"));
            array_push(guide_steps, gs_mix(   spr_MixHint,      "Put the sliced veggies in the mixer",OBJ_Vegetables, "sliced", OBJ_Lumpia, "raw_veggie_lumpia"));
            array_push(guide_steps, gs_exists(spr_WrapperHint,  "Add a lumpia wrapper to the mixer",  OBJ_Lumpia,     "raw_veggie_lumpia"));
            array_push(guide_steps, gs_exists(spr_FryHint,      "Fry the lumpia in a pan",            OBJ_Lumpia,     "cooked_veggie_lumpia"));
            array_push(guide_steps, gs_plated(spr_PlateHint,    "Serve it on a plate",                OBJ_Lumpia,     "cooked_veggie_lumpia", spr_veggielumpiadish));
            break;

        case "caldereta":
            guide_name = "Caldereta";
            array_push(guide_steps, gs_held(  spr_FridgeHint,   "Take meat from the freezer",       OBJ_Meat,       "raw"));
            array_push(guide_steps, gs_exists(spr_SliceHint,    "Slice the meat",                   OBJ_Meat,       "sliced"));
            array_push(guide_steps, gs_exists(spr_SauceHint,    "Add sauce to the sliced meat",     OBJ_Meat,       "soy_sliced"));
            array_push(guide_steps, gs_held(  spr_VegetableHint,"Take veggies from veggie storage", OBJ_Vegetables, "raw"));
            array_push(guide_steps, gs_exists(spr_SliceHint,    "Slice the veggies",                OBJ_Vegetables, "sliced"));
            array_push(guide_steps, gs_exists(spr_MixHint,      "Mix the sauced meat and veggies",  OBJ_Caldereta,  "raw_caldereta"));
            array_push(guide_steps, gs_exists(spr_PotHint,      "Cook it in the pot",               OBJ_Caldereta,  "cooked_caldereta"));
            array_push(guide_steps, gs_plated(spr_PlateHint,    "Serve it on a plate",              OBJ_Caldereta,  "cooked_caldereta", spr_calderetadish));
            break;
    }

    if (array_length(guide_steps) > 0) {
        guide_active = true;
        guide_step = 0;
    }
}
