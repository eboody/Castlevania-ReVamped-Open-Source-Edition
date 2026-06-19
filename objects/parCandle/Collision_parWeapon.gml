/// @description spawn item and destroy
if !broken
{
	broken = true
	if global.vibration
		input_vibrate_constant(0.12,0,2)

	if global.hitstop_frames <= 0
	{
		global.hitstop_speed_restore = game_get_speed(gamespeed_fps)
		game_set_speed(max(10,global.hitstop_speed_restore div 3),gamespeed_fps)
	}
	global.hitstop_frames = max(global.hitstop_frames,1)
	if other.object_index = objWhip
		scrStartScreenshake(48,0.7)
	instance_create(x,y,item_id)
	instance_destroy()
}
