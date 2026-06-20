/// @description follow the player
if room_width <= 400
{
	camera_set_view_target(view_camera,noone)
	var _camera_y = 0
	if player_exists()
	{
		_camera_y = parPlayer.y - 112
		if _camera_y < 0
			_camera_y = 0
		if _camera_y > room_height - 224
			_camera_y = room_height - 224
		if room_height <= 224
			_camera_y = 0
	}
	camera_set_view_pos(view_camera,-49,_camera_y)
}
else
	camera_set_view_target(view_camera,parPlayer)
if player_exists()
{
	if instance_number(objFadeInShutter) > 0//parPlayer.hazard_damage
	{
		camera_set_view_speed(view_camera,6669,6669)
		alarm[0] = 5
	}
}