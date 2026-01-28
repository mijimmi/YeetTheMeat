// Only destroy cloud_list if it was created
if (variable_instance_exists(id, "cloud_list")) {
    ds_list_destroy(cloud_list);
}
