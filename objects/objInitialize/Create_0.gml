/// @description file independent variables + BGM loop points
depth = -16000000
global.options = ds_map_create()

//load options
if (!file_exists("Castlevania_Options.sav"))
{
	global.volumeSFX = 1
	global.volumeBGM = 1
	global.vibration = true
	global.crt = false
	global.debug_hitbox_overlay = false
	ds_map_replace(global.options,"video_aspect",aspect_default_index())
	
	if ds_map_find_value( global.options,"icon files 0" ) = undefined
		ds_map_replace( global.options,"icon file 0",0 )
	if ds_map_find_value( global.options,"icon files 1" ) = undefined
		ds_map_replace( global.options,"icon file 1",0 )
	if ds_map_find_value( global.options,"icon files 2" ) = undefined
		ds_map_replace( global.options,"icon file 2",0 )
}
else
{
	global.options = ds_map_secure_load("Castlevania_Options.sav")
	
	global.volumeSFX = ds_map_find_value(global.options,"volumeSFX")
	global.volumeBGM = ds_map_find_value(global.options,"volumeBGM")
	global.vibration = ds_map_find_value(global.options,"vibration")
	if ds_map_find_value(global.options,"crt") != undefined
		global.crt = ds_map_find_value(global.options,"crt")
	else
		global.crt = false
	
	if ds_map_find_value(global.options,"windowscale") = undefined
		ds_map_replace(global.options,"windowscale",1)
	if ds_map_find_value(global.options,"fullscreen") = undefined
		ds_map_replace(global.options,"fullscreen",false)
	if ds_map_find_value(global.options,"debug_hitbox_overlay") = undefined
		ds_map_replace(global.options,"debug_hitbox_overlay",false)
	global.debug_hitbox_overlay = ds_map_find_value(global.options,"debug_hitbox_overlay")
	if ds_map_find_value(global.options,"video_aspect") = undefined
		ds_map_replace(global.options,"video_aspect",aspect_default_index())
	aspect_option_init()
		
	window_set_fullscreen(ds_map_find_value(global.options,"fullscreen"))
	aspect_window_set_size();
}

aspect_option_init()
aspect_apply_surface()
aspect_window_set_size()

//load controls if they exist
if ds_map_find_value(global.options,"controls") != undefined
	input_system_import(ds_map_find_value(global.options,"controls"))
	
//load ending cards
global.gallery = ds_map_create()

if (!file_exists("Castlevania_Endings.sav"))
{
	ds_map_replace(global.gallery,"ending0",0)
	ds_map_replace(global.gallery,"ending1",0)
	ds_map_replace(global.gallery,"ending2",0)
	ds_map_replace(global.gallery,"ending3",0)
	ds_map_replace(global.gallery,"bossrush",0)
	ds_map_replace(global.gallery,"record_secs",359999)
	ds_map_replace(global.gallery,"record","--:--:--\n$----")
	ds_map_secure_save(global.gallery,"Castlevania_Endings.sav")
}
else
	global.gallery = ds_map_secure_load("Castlevania_Endings.sav")

///@description Initilize System and add palettes

//This should be done before any drawing takes place 
//in a managing object that will persist through the entire game.
//Notice I've set it to persistent.  

//First Init the System, specify the name of the pal swap shader in case you've changed it for some reason.
pal_swap_init_system(shd_pal_swapper);

set_loop_points()