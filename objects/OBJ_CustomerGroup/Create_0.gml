// Group management object (invisible)
visible = false;

group_size = 0;           // How many customers in this group (1-4)
customers = [];           // Array of customer instances in this group
assigned_table = noone;   // Which table they're going to
group_state = "walking";  // "walking", "seated", "waiting", "leaving"