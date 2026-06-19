/// @description spawn item and destroy
if !broken
{
	broken = true
	instance_create(x,y,item_id)
	instance_destroy()
}
