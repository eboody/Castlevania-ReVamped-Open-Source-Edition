/// @description control shit
scrControls()
bitBGM(bgmUnderground)

if kUpTap
{
	bitsound(sndWeaponWhip)
	selection += -1
	if selection <= 0
		selection = 0
}

if kDownTap
{
	bitsound(sndWeaponWhip)
	selection += 1
	if selection >= 12
		selection = 12
}

//set options
if kRightTap
{
	bitsound(sndMenuSelect)
	if selection = 0 //sfx
		{
			global.volumeSFX += 0.1
			if global.volumeSFX >= 1
				global.volumeSFX = 1
			ds_map_replace(global.options,"volumeSFX",global.volumeSFX)
		}
	if selection = 1 //bgm
		{
			audio_stop_all()
			global.volumeBGM += 0.1
			if global.volumeBGM >= 1
				global.volumeBGM = 1
			ds_map_replace(global.options,"volumeBGM",global.volumeBGM)
		}
	if selection = 2 //vibration
		{
			global.vibration = true
			ds_map_replace(global.options,"vibration",global.vibration)
		}
	if selection = 3 //debug hitboxes
		{
			global.debug_hitbox_overlay = true
			ds_map_replace(global.options,"debug_hitbox_overlay",global.debug_hitbox_overlay)
		}
	if selection = 8 //aspect ratio
		{
			var _aspect = aspect_get_index() + 1
			if _aspect >= aspect_count()
				_aspect = 0
			aspect_set_index(_aspect)
			aspect_window_set_size()
		}
	if selection = 9 //window scale
		{
			if ds_map_find_value(global.options,"windowscale") < 7
				ds_map_replace(global.options,"windowscale",ds_map_find_value(global.options,"windowscale")+1)
			aspect_window_set_size();
		}
	if selection = 10 //fullscreen
		{
			ds_map_replace(global.options,"fullscreen",true)
			window_set_fullscreen(ds_map_find_value(global.options,"fullscreen"))
		}
	if selection = 11 //crt
		{
			ds_map_replace(global.options,"crt",true)
			global.crt = true
		}
}

if kLeftTap
{
	bitsound(sndMenuSelect)
	if selection = 0 //sfx
		{
			global.volumeSFX += -0.1
			if global.volumeSFX <= 0
				global.volumeSFX = 0
			ds_map_replace(global.options,"volumeSFX",global.volumeSFX)
		}
	if selection = 1 //bgm
		{
			audio_stop_all()
			global.volumeBGM += -0.1
			if global.volumeBGM <= 0
				global.volumeBGM = 0
			ds_map_replace(global.options,"volumeBGM",global.volumeBGM)
		}
	if selection = 2 //vibration
		{
			global.vibration = false
			ds_map_replace(global.options,"vibration",global.vibration)
		}
	if selection = 3 //debug hitboxes
		{
			global.debug_hitbox_overlay = false
			ds_map_replace(global.options,"debug_hitbox_overlay",global.debug_hitbox_overlay)
		}
	if selection = 8 //aspect ratio
		{
			var _aspect = aspect_get_index() - 1
			if _aspect < 0
				_aspect = aspect_count() - 1
			aspect_set_index(_aspect)
			aspect_window_set_size()
		}
	if selection = 9 //window scale
		{
			if ds_map_find_value(global.options,"windowscale") > 1
				ds_map_replace(global.options,"windowscale",ds_map_find_value(global.options,"windowscale")-1)
			aspect_window_set_size();
		}
	if selection = 10 //fullscreen
		{
			ds_map_replace(global.options,"fullscreen",false)
			window_set_fullscreen(ds_map_find_value(global.options,"fullscreen"))
		}
	if selection = 11 //crt
		{
			ds_map_replace(global.options,"crt",false)
			global.crt = false
		}
}

if kAccept //control customizing, default values, credits, or leave
{
	bitsound(sndMenuSelect)
	if selection = 3 //debug hitboxes
	{
		global.debug_hitbox_overlay = !global.debug_hitbox_overlay
		ds_map_replace(global.options,"debug_hitbox_overlay",global.debug_hitbox_overlay)
		ds_map_secure_save(global.options,"Castlevania_Options.sav")
	}
	if selection = 4 //main controls
	{
		room_goto(rmControlOptions)
		ds_map_secure_save(global.options,"Castlevania_Options.sav")
	}
	if selection = 5 //menu controls
	{
		room_goto(rmMenuOptions)
		ds_map_secure_save(global.options,"Castlevania_Options.sav")
	}
	if selection = 6 //default values sans controls
	{
		global.volumeSFX = 1
		global.volumeBGM = 1
		global.vibration = true	
		global.debug_hitbox_overlay = false
		aspect_set_index(aspect_default_index())
		audio_stop_all()
		ds_map_replace(global.options,"volumeSFX",global.volumeSFX)
		ds_map_replace(global.options,"volumeBGM",global.volumeBGM)
		ds_map_replace(global.options,"vibration",global.vibration)
		ds_map_replace(global.options,"debug_hitbox_overlay",global.debug_hitbox_overlay)
		ds_map_replace(global.options,"video_aspect",aspect_get_index())
	}
	if selection = 7 //credits
	{
		ds_map_secure_save(global.options,"Castlevania_Options.sav")
		room_goto(rmCreditsOptions)
	}
	if selection = 12 //exit
	{
		ds_map_secure_save(global.options,"Castlevania_Options.sav")
		room_goto(rmFileSelect)
	}
}

if kCancel
{
	bitsound(sndWeaponWhip)
	ds_map_secure_save(global.options,"Castlevania_Options.sav")
	room_goto(rmFileSelect)
}