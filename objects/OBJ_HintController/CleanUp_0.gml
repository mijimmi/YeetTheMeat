// Clean up the hint map
if (ds_exists(hint_map, ds_type_map)) {
    ds_map_destroy(hint_map);
}
