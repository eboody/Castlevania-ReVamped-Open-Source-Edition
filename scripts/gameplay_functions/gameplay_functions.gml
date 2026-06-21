function destroy_tile()
{
	var layer_id = layer_tilemap_get_id(layer_get_id("Tiles"));
	tilemap_set_at_pixel(layer_id, 0, x, y);	
}

function door(target_x,target_y,target_room)
{
	tx = argument0
	ty = argument1
	troom = argument2
}

function boss_entry_gate_passed(_spawner_x)
{
	if !player_exists()
		return false;
	if instance_number(parGate) <= 0
		return true;
	
	var _from_left = parPlayer.x < _spawner_x;
	var _gate_x = undefined;
	var _count = instance_number(parGate);
	for (var i = 0; i < _count; i++)
	{
		var _gate = instance_find(parGate,i);
		if !instance_exists(_gate)
			continue;
		
		if _from_left
		{
			if _gate.xstart <= _spawner_x
			{
				if is_undefined(_gate_x) || _gate.xstart > _gate_x
					_gate_x = _gate.xstart;
			}
		}
		else
		{
			if _gate.xstart >= _spawner_x
			{
				if is_undefined(_gate_x) || _gate.xstart < _gate_x
					_gate_x = _gate.xstart;
			}
		}
	}
	
	if is_undefined(_gate_x)
		return true;
	
	if _from_left
		return parPlayer.bbox_left > _gate_x + 16;
	else
		return parPlayer.bbox_right < _gate_x;
}

function area_setup(area_number,map_x,map_y)
{
	global.area = argument0
	global.mx = argument1
	global.my = argument2
}

function draw_item()
{
	current_pal = 0
	counter += 1
	if counter/60 = round(counter/60) or (counter + 4)/60 = round( (counter + 4)/60 )
		current_pal = 8
	draw_palette_ext(palGlobal,current_pal,x,y)
}

function draw_upgrade()
{
	counter += 1
	if counter/15 = round(counter/15)
	{
		current_pal += 9
		if current_pal > 9
			current_pal = 0
	}
	draw_palette_ext(palGlobal,current_pal,x,y)
}