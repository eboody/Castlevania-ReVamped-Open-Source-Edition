/// @description copy playaaa
trail_source_dash = false
trail_source_slide = false
trail_source_pound = false
trail_lifetime = 4 * 3
trail_dash_end_linger = 0

if player_exists() = true && instance_number(objSimon) > 0
{
	sprite_index = parPlayer.sprite_index
	image_index = parPlayer.image_index
	image_speed = 0
	trail_source_dash = parPlayer.dashing
	trail_source_slide = parPlayer.sliding
	trail_source_pound = parPlayer.pounding
	if trail_source_dash
		trail_lifetime = 3
}

fadeframe = 0

depth = 1

scrViewData()

//surfacewithmask = surface_create(sprite_get_width(sprite_index), sprite_get_height(sprite_index));
