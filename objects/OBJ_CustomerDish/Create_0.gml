// Lightweight prop that renders a seated customer's served dish(es) on the table.
// It exists as a separate instance so it can sort IN FRONT of the spr_BGdepth
// table layer even when its owner (a north-seated customer) is drawn behind it.
owner = noone;   // the OBJ_Customer_Parent this dish belongs to
