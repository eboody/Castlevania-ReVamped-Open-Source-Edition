function scrStartScreenshake(_frames,_magnitude)
{
	// Screen shake intentionally disabled globally.
	global.screenshake_frames = 0
	global.screenshake_duration = 0
	global.screenshake_magnitude = 0
}

function scrEnemyHurt()
{
	if ( i_frames = 0 ) or ( i_frames <= 1 && other.object_index = objWhip )
	{
		if other.object_index = objWhip
		{
			if variable_instance_exists(id,"last_whip_hit_id") && last_whip_hit_id = other.id
				return;
			last_whip_hit_id = other.id;
		}
		
		//damage numbers with critical card
		if global.critical_card = 2
		{
			reported_value = other.damage
			with( instance_create_depth(x,y,0,objDamageNumber) )
				value = other.reported_value
		}
		//proper sfx
		hp += -other.damage
		i_frames = max(2,ceil(other.i_frames / 2))
		instance_create(x,y,objExplosionSmall)
		if global.vibration
			input_vibrate_constant(0.18,0,3)

		if global.hitstop_frames <= 0
		{
			global.hitstop_speed_restore = game_get_speed(gamespeed_fps)
			game_set_speed(max(8,global.hitstop_speed_restore div 2),gamespeed_fps)
		}
		global.hitstop_frames = max(global.hitstop_frames,1)
		if other.object_index = objWhip && global.current_whip = 2
			bitsound(sndEnemyHit0)
		else
		{
			if max_hp > 30
				bitsound(sndEnemyHit1)
			else
				if hp >= 0
					bitsound(sndEnemyHit2)
		}
		if hp <= 0
		{//kill the enemy
			if other.object_index = objWhip
				scrStartScreenshake(64,0.8)
			bitsound(sndEnemyBoom0)
			instance_destroy()
		}
		else if other.object_index = objWhip
			scrStartScreenshake(56,1.8)
		//spawn a critical hit thing if critical and also reduce the damage to normal
		if other.critical
		{
			instance_create(x,y,objCriticalHit)
			other.critical = false
			other.damage = other.og_damage
			if irandom(7) = 3 with(other) alarm[11] = 1
		}
		
		if object_index = objBossMirrorMonster
		{
			repeat(3) instance_create(x,y,objDebris)
			bitsound(sndGlassBreak)
		}
		
		nofade = false
		if enemy_number != 9999
		{
			if instance_number(objEnemyNametag) > 0
			{
				instance_destroy(objEnemyNametag)
				nofade = true
			}
			with( instance_create_depth(x,y,0,objEnemyNametag) )
			{
				if other.nofade
					fade = 2
				name_text = enemy_nametags(other.enemy_number)
			}
		}
				
		if boss_number != 9999
		{
			if instance_number(objEnemyNametag) > 0
			{
				instance_destroy(objEnemyNametag)
				nofade = true
			}
			with( instance_create_depth(x,y,0,objEnemyNametag) )
			{
				if other.nofade
					fade = 2
				name_text = boss_nametags(other.boss_number)
			}
		}
	}
}

function scrEnemyDraw()
{
	current_pal = 0
	if i_frames > 0
	{
		if i_frames/2 = round(i_frames/2)
			current_pal = 9
		else
			current_pal = 8
	}
	draw_palette_ext(palGlobal,current_pal,x,y)
}

function ai_lap()
{
	ai_step += 1
	counter = 0
	image_index = 0
}

function face_player(tolerance)
{
	if parPlayer.x - argument0 < x
		image_xscale = -1
	if parPlayer.x + argument0 > x
		image_xscale = 1	
}

function in_view()
{
	scrViewData()
	
	if x > xview -16 && x < xview + wview + 16 && y > yview - 8 && y < yview + hview + 8
		return true;
	else
		return false;
}

function create_bossbar()
{
	with( instance_create_depth(x,y,0,objBossBar) )
		hp_id = other.id
}

function scrStoneManMultiply()
{
	if original
		with( instance_create_depth(x,y,0,object_index) )
		{
			original = false
			hp = other.hp
			i_frames = other.i_frames
			image_xscale = other.image_xscale * -1
			yspeed = -2
			alarm[0] = 5
		}	
}

function enemy_weapon()
{
	with( instance_create_depth(x,y,0,objEnemyWeapon) )
		special_id = other.id
}