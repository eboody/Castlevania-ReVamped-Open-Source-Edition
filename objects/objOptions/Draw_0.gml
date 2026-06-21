/// @description the menu
scrViewData()
draw_set_font(fntMessage)
draw_set_halign(fa_left)
draw_set_color(c_white)
nes_colors()

vibratetext = "";

if global.volumeBGM = undefined
	global.volumeBGM = 1
if global.volumeSFX = undefined
	global.volumeSFX = 1
if global.vibration = undefined
	global.vibration = true
	
if !variable_global_exists("debug_hitbox_overlay")
	global.debug_hitbox_overlay = false
	
if ds_map_find_value(global.options,"windowscale") = undefined
		ds_map_replace(global.options,"windowscale",1)
if ds_map_find_value(global.options,"fullscreen") = undefined
		ds_map_replace(global.options,"fullscreen",false)
if ds_map_find_value(global.options,"debug_hitbox_overlay") = undefined
		ds_map_replace(global.options,"debug_hitbox_overlay",global.debug_hitbox_overlay)
if ds_map_find_value(global.options,"video_aspect") = undefined
		ds_map_replace(global.options,"video_aspect",aspect_default_index())
aspect_option_init()
		aspecttext = "Aspect Ratio - " + aspect_get_label()
windowtext = "Window Scale - " + string(ds_map_find_value(global.options,"windowscale"))
fullscreentext = "Fullscreen - [Off]   On "
if ds_map_find_value(global.options,"fullscreen") = true
	fullscreentext = "Fullscreen -  Off   [On]"
	
SFXtext = "SFX Volume - " + string( round(global.volumeSFX * 100) ) + "%"
BGMtext = "BGM Volume - " + string( round(global.volumeBGM * 100) ) + "%"

if global.vibration
	vibratetext = "Vibration -  Off   [On]"
else
	vibratetext = "Vibration - [Off]   On "

if global.crt
	crttext = "CRT Filter -  Off   [On]"
else
	crttext = "CRT Filter - [Off]   On "
	
if global.debug_hitbox_overlay
	hitboxtext = "Debug Hitboxes -  Off   [On]"
else
	hitboxtext = "Debug Hitboxes - [Off]   On "

draw_text(x,y,SFXtext)
draw_text(x,y + 16,BGMtext)
draw_text(x,y + 32,vibratetext)
draw_text(x,y + 48,hitboxtext)
draw_text(x,y + 64,"Game Input Settings")
draw_text(x,y + 80,"Menu Input Settings")
draw_text(x,y + 96,"Restore Defaults")
draw_text(x,y + 112,"Credits")
draw_text(x,y + 128,aspecttext)
draw_text(x,y + 144,windowtext)
draw_text(x,y + 160,fullscreentext)
draw_text(x,y + 176,crttext)
draw_text(x,y + 192,"Back")

draw_set_color(nes_yellow)

if selection = 0
	draw_text(x,y,SFXtext)
if selection = 1
	draw_text(x,y + 16,BGMtext)
if selection = 2
	draw_text(x,y + 32,vibratetext)
if selection = 3
	draw_text(x,y + 48,hitboxtext)
if selection = 4
	draw_text(x,y + 64,"Game Input Settings")
if selection = 5
	draw_text(x,y + 80,"Menu Input Settings")
if selection = 6
	draw_text(x,y + 96,"Restore Defaults")
if selection = 7
	draw_text(x,y + 112,"Credits")
if selection = 8
	draw_text(x,y + 128,aspecttext)
if selection = 9
	draw_text(x,y + 144,windowtext)
if selection = 10
	draw_text(x,y + 160,fullscreentext)
if selection = 11
	draw_text(x,y + 176,crttext)
if selection = 12
	draw_text(x,y + 192,"Back")
