/// @description enforce black bars for non-widenable 20:9 scenes
// Some title/menu/cinematic rooms are authored for the original 400x224 canvas.
// They use a wider 498x224 camera with x=-49 so the 400px canvas is centered.
// Redraw the side bands *after* normal drawing so backgrounds, transitions, or
// stray sprites cannot write into the pillarbox area.
var _view_x = camera_get_view_x(view_camera);
var _view_y = camera_get_view_y(view_camera);
var _view_w = camera_get_view_width(view_camera);
var _view_h = camera_get_view_height(view_camera);
var _view_r = _view_x + _view_w;
var _view_b = _view_y + _view_h;

// Treat rooms that cannot provide extra horizontal world area as 16:9-safe-area
// scenes.  The centered static-room camera also has negative x, which catches
// menu/title/cinematic rooms explicitly configured that way.
if room_width <= 400 || _view_x < 0 || instance_exists(objIntroSimon)
{
	draw_set_alpha(1);
	draw_set_colour(c_black);
	
	if _view_x < 0
		draw_rectangle(_view_x, _view_y, 0, _view_b, false);
	
	if _view_r > 400
		draw_rectangle(400, _view_y, _view_r, _view_b, false);
}
