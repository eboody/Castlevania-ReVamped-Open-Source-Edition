/// @description follow the player
if aspect_is_safe_area_scene()
{
	camera_set_view_target(view_camera,noone)
	camera_set_view_pos(view_camera,aspect_safe_area_camera_x(),aspect_safe_area_camera_y())
}
else
{
	aspect_apply_camera()
}
if player_exists()
{
	if instance_number(objFadeInShutter) > 0//parPlayer.hazard_damage
	{
		camera_set_view_speed(view_camera,6669,6669)
		alarm[0] = 5
	}
}
