// Clean up smoke particle list to prevent memory leak
if (ds_exists(smoke_list, ds_type_list)) {
    ds_list_destroy(smoke_list);
}
