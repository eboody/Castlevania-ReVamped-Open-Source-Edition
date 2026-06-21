/// @description Runtime aspect ratio helpers for Android variants

function aspect_base_width()
{
	return 400;
}

function aspect_base_height()
{
	return 224;
}

function aspect_count()
{
	return 5;
}

function aspect_default_index()
{
	return 0; // 20:9
}

function aspect_clamp_index(_index)
{
	if _index == undefined
		_index = aspect_default_index();
	_index = floor(_index);
	if _index < 0
		_index = 0;
	if _index >= aspect_count()
		_index = aspect_count() - 1;
	return _index;
}

function aspect_option_init()
{
	if !variable_global_exists("options")
		return;
	if ds_map_find_value(global.options,"video_aspect") == undefined
		ds_map_replace(global.options,"video_aspect",aspect_default_index());
	global.video_aspect = aspect_clamp_index(ds_map_find_value(global.options,"video_aspect"));
	ds_map_replace(global.options,"video_aspect",global.video_aspect);
}

function aspect_get_index()
{
	if !variable_global_exists("video_aspect")
		global.video_aspect = aspect_default_index();
	return aspect_clamp_index(global.video_aspect);
}

function aspect_set_index(_index)
{
	global.video_aspect = aspect_clamp_index(_index);
	if variable_global_exists("options")
		ds_map_replace(global.options,"video_aspect",global.video_aspect);
	aspect_apply_surface();
	aspect_apply_camera();
}

function aspect_get_width()
{
	switch (aspect_get_index())
	{
		case 0: return 498; // 20:9 at 224px tall
		case 1: return 400; // original 16:9-ish authored canvas
		case 2: return 299; // 4:3 at 224px tall, rounded
		case 3: return 336; // 3:2 at 224px tall
		case 4: return 224; // 1:1
	}
	return 498;
}

function aspect_get_height()
{
	return 224;
}

function aspect_get_label()
{
	switch (aspect_get_index())
	{
		case 0: return "20:9";
		case 1: return "16:9";
		case 2: return "4:3";
		case 3: return "3:2";
		case 4: return "1:1";
	}
	return "20:9";
}

function aspect_apply_surface()
{
	var _w = aspect_get_width();
	var _h = aspect_get_height();
	if surface_exists(application_surface)
	{
		if surface_get_width(application_surface) != _w || surface_get_height(application_surface) != _h
			surface_resize(application_surface,_w,_h);
	}
	display_set_gui_size(_w,_h);
}

function aspect_window_set_size()
{
	var _scale = 1;
	if variable_global_exists("options") && ds_map_find_value(global.options,"windowscale") != undefined
		_scale = ds_map_find_value(global.options,"windowscale");
	window_set_size(aspect_get_width() * _scale, aspect_get_height() * _scale);
}

function aspect_is_safe_area_scene()
{
	return room_width <= aspect_base_width() || instance_exists(objIntroSimon);
}

function aspect_apply_camera()
{
	if !camera_exists(view_camera)
		return;
	var _target_w = aspect_get_width();
	var _target_h = aspect_get_height();
	var _view_w = _target_w;
	var _view_h = _target_h;
	var _view_x = 0;
	var _view_y = 0;
	
	if aspect_is_safe_area_scene()
	{
		if _target_w >= aspect_base_width()
		{
			_view_w = _target_w;
			_view_h = aspect_base_height();
			_view_x = (aspect_base_width() - _target_w) / 2;
			_view_y = 0;
		}
		else
		{
			_view_w = aspect_base_width();
			_view_h = round(aspect_base_width() * _target_h / _target_w);
			_view_x = 0;
			_view_y = (aspect_base_height() - _view_h) / 2;
		}
		camera_set_view_target(view_camera,noone);
		camera_set_view_pos(view_camera,_view_x,_view_y);
	}
	else
	{
		camera_set_view_target(view_camera,parPlayer);
	}
	
	camera_set_view_size(view_camera,_view_w,_view_h);
	view_set_wport(view_camera,_target_w);
	view_set_hport(view_camera,_target_h);
	view_set_xport(view_camera,0);
	view_set_yport(view_camera,0);
	camera_set_view_border(view_camera,ceil(_view_w/2),ceil(_view_h/2));
}

function aspect_safe_area_camera_y()
{
	var _target_w = aspect_get_width();
	var _target_h = aspect_get_height();
	var _view_h = _target_h;
	if _target_w < aspect_base_width()
		_view_h = round(aspect_base_width() * _target_h / _target_w);
	var _camera_y = (aspect_base_height() - _view_h) / 2;
	if player_exists()
	{
		_camera_y = parPlayer.y - (_view_h/2);
		if _camera_y < (aspect_base_height() - _view_h) / 2
			_camera_y = (aspect_base_height() - _view_h) / 2;
		if _camera_y > room_height - _view_h
			_camera_y = room_height - _view_h;
		if room_height <= _view_h
			_camera_y = (aspect_base_height() - _view_h) / 2;
	}
	return _camera_y;
}

function aspect_safe_area_camera_x()
{
	var _target_w = aspect_get_width();
	if _target_w >= aspect_base_width()
		return (aspect_base_width() - _target_w) / 2;
	return 0;
}

function aspect_screen_sprite_from_surface()
{
	return sprite_create_from_surface(application_surface,0,0,aspect_get_width(),aspect_get_height(),false,false,0,0);
}

function aspect_draw_black_bars()
{
	if !camera_exists(view_camera)
		return;
	if !aspect_is_safe_area_scene()
		return;
	var _view_x = camera_get_view_x(view_camera);
	var _view_y = camera_get_view_y(view_camera);
	var _view_w = camera_get_view_width(view_camera);
	var _view_h = camera_get_view_height(view_camera);
	var _view_r = _view_x + _view_w;
	var _view_b = _view_y + _view_h;
	
	draw_set_alpha(1);
	draw_set_colour(c_black);
	
	if _view_x < 0
		draw_rectangle(_view_x,_view_y,0,_view_b,false);
	if _view_r > aspect_base_width()
		draw_rectangle(aspect_base_width(),_view_y,_view_r,_view_b,false);
	if _view_y < 0
		draw_rectangle(_view_x,_view_y,_view_r,0,false);
	if _view_b > aspect_base_height()
		draw_rectangle(_view_x,aspect_base_height(),_view_r,_view_b,false);
}
