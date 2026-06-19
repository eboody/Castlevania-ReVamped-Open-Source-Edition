/// @description set to proper frame / destroy properly
if player_exists() = true
{
	image_index = parPlayer.image_index
	if !parPlayer.attacking
		instance_destroy()
	x = parPlayer.x
	y = parPlayer.y
	if parPlayer.ducking
		y += 8
	
	// Standard whip collision comes from this object's sprite mask, which starts
	// outside Simon's body. Also hurt enemies that are already overlapping Simon
	// during the active whip window so point-blank enemies can still be struck.
	if parPlayer.whip_out
	{
		with(parEnemy)
		{
			if place_meeting(x,y,parPlayer)
			{
				if !other.struck
				{
					if global.healingstrike_card = 2
						global.healing_strike_count += 1
					if global.healing_strike_count >= 6
					{
						global.hp += 1
						global.healing_strike_count = 0
						bitsound(sndPickupHealth)
					}
					if global.cardiacstrike_card = 2
						instance_create(x,y,objItemHeart)
					other.struck = true
				}
				scrEnemyHurt()
			}
		}
		
		// Match the same point-blank behavior for breakables whose masks can sit
		// underneath Simon while the whip mask is already out in front of him.
		with(parCandle)
		{
			if place_meeting(x,y,parPlayer) && !broken
			{
				broken = true
				instance_create(x,y,item_id)
				instance_destroy()
			}
		}
		
		with(objBlockNormal)
		{
			if place_meeting(x,y,parPlayer) && !variable_instance_exists(id,"whip_overlap_broken")
			{
				whip_overlap_broken = true
				bitsound(sndBlockBreak)
				instance_destroy()
			}
		}
		
		with(objBlockMorningstar)
		{
			if place_meeting(x,y,parPlayer) && other.flavor > 0 && !variable_instance_exists(id,"whip_overlap_broken")
			{
				whip_overlap_broken = true
				bitsound(sndBlockBreak)
				instance_destroy()
			}
		}
		
		with(objBlockFlame)
		{
			if place_meeting(x,y,parPlayer) && other.flavor = 2 && !variable_instance_exists(id,"whip_overlap_broken")
			{
				whip_overlap_broken = true
				bitsound(sndBlockBreak)
				instance_destroy()
			}
		}
		
		with(objBlockIce)
		{
			if place_meeting(x,y,parPlayer) && other.flavor = 3 && !variable_instance_exists(id,"whip_overlap_broken")
			{
				whip_overlap_broken = true
				bitsound(sndBlockBreak)
				instance_destroy()
			}
		}
		
		with(objBlockThunder)
		{
			if place_meeting(x,y,parPlayer) && other.flavor = 4 && !variable_instance_exists(id,"whip_overlap_broken")
			{
				whip_overlap_broken = true
				bitsound(sndBlockBreak)
				instance_destroy()
			}
		}
	}
}
else
	instance_destroy()
	

//flash a whip sprite in when an elemental
if global.current_whip > 1
{
	if aim_dir = FORWARD
		chain_sprite = sprWhipMorningstar
	if aim_dir = UP
		chain_sprite = sprWhipMorningstarUp
	if aim_dir = UP_DIAG
		chain_sprite = sprWhipMorningstarUpDiag
	if aim_dir = DOWN
		chain_sprite = sprWhipMorningstarDown
	if aim_dir = DOWN_DIAG
		chain_sprite = sprWhipMorningstarDownDiag
}
