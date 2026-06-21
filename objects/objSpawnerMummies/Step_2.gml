/// @description sense player and start fight
if mummy_order = 0
{
	if active && instance_number(objSimonDie) = 0
	{
		global.boss_music = true
		bitBGM(bgmCreaturesInTheDepth)
	}
	else
		global.boss_music = false


	if !active && abs(parPlayer.x - x) < eyesight && boss_entry_gate_passed(x)
	{
		active = true
		alarm[0] = 120
		with( parGate ) 
			x = xstart
	}
}
