/// @description follow the player
camera_set_view_target(view_camera,parPlayer)
if player_exists()
{
	if global.screenshake_frames > 0
	{
		var _shake = global.screenshake_magnitude
		camera_set_view_pos(view_camera,camera_get_view_x(view_camera) + irandom_range(-_shake,_shake),camera_get_view_y(view_camera) + irandom_range(-_shake,_shake))
	}

	if instance_number(objFadeInShutter) > 0//parPlayer.hazard_damage
	{
		camera_set_view_speed(view_camera,6669,6669)
		alarm[0] = 5
	}
}