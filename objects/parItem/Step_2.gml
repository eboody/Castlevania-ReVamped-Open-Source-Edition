/// @description physics for falling + invisible when hidden
scrPhysics()
if place_meeting(x,y,parSolid)
	visible = false
else
	visible = true
	
if player_exists() = true && visible
{
	var _magnet_distance = 5
	var _distance = point_distance(x,y,parPlayer.x,parPlayer.y)
	if _distance > 2 && _distance < _magnet_distance
	{
		var _pull = 1 - (_distance / _magnet_distance)
		xspeed += ((parPlayer.x - x) / _distance) * _pull * 0.55
		yspeed += ((parPlayer.y - y) / _distance) * _pull * 0.55
		xspeed = clamp(xspeed,-4,4)
		yspeed = clamp(yspeed,-4,4)
	}
}

xspeed *= 0.9