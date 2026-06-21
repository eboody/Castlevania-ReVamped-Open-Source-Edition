function scrControls()
{//controls
	kLeft = input_check("left");
	kRight= input_check("right");
	kUp= input_check("up");
	kDown= input_check("down");

	kAttack= input_check_pressed("attack"); kAttackHold= input_check("attack");
	kJump= input_check_pressed("jump");	kJumpRelease= input_check_released("jump");
	kSubweapon = input_check_pressed("subweapon");
	kDash = input_check("dash");
	
	kSwap = input_check_pressed("swap");
	
	kAimLock = input_check("aimlock");

	kAccept= input_check_pressed("accept");
	kCancel= input_check_pressed("cancel");
	kPause= input_check_pressed("pause"); kPauseHold= input_check("pause");
	kMap= input_check_pressed("map");
	
	if variable_global_exists("debug_hitbox_toggle_suppress") && global.debug_hitbox_toggle_suppress > 0
	{
		kMap = false;
		kPause = false;
		kPauseHold = false;
	}

	//tapping, for menus
	kLeftTap = input_check_pressed("left");
	kRightTap = input_check_pressed("right");
	kUpTap = input_check_pressed("up");
	kDownTap = input_check_pressed("down");
}

function scrDebugHitboxOverlayDraw()
{
	var _enabled = variable_global_exists("debug_hitbox_overlay") && global.debug_hitbox_overlay;
	var _notice = variable_global_exists("debug_hitbox_toggle_notice") && global.debug_hitbox_toggle_notice > 0;
	
	if !_enabled && !_notice
		return;
	
	var _old_alpha = draw_get_alpha();
	var _old_colour = draw_get_colour();
	
	if _enabled
	{
		scrDebugHitboxOverlayDrawGroup(parPlayer,c_lime);
		scrDebugHitboxOverlayDrawWhip(c_aqua);
		scrDebugHitboxOverlayDrawGroup(parEnemy,c_red);
		scrDebugHitboxOverlayDrawGroup(parCandle,c_yellow);
		scrDebugHitboxOverlayDrawGroup(objBlockNormal,c_orange);
		scrDebugHitboxOverlayDrawGroup(objBlockMorningstar,c_orange);
		scrDebugHitboxOverlayDrawGroup(objBlockFlame,c_orange);
		scrDebugHitboxOverlayDrawGroup(objBlockIce,c_orange);
		scrDebugHitboxOverlayDrawGroup(objBlockThunder,c_orange);
		scrDebugHitboxOverlayDrawGroup(objBlockPound,c_orange);
		scrDebugHitboxOverlayDrawGroup(objBlockSlide,c_orange);
		scrDebugHitboxOverlayDrawRects(scrWhipBackswingHitboxRects(),c_aqua);
		
		draw_set_alpha(1);
		draw_set_colour(c_white);
		draw_text_outline(xview + 4,yview + hview - 18,c_black,c_white,"Hitboxes: ON (LB+Start / H)");
	}
	
	if _notice
	{
		var _state_text = "Hitbox overlay ON";
		if !_enabled
			_state_text = "Hitbox overlay OFF";
		
		draw_text_outline(xview + 200,yview + 96,c_black,c_white,_state_text);
	}
	
	draw_set_alpha(_old_alpha);
	draw_set_colour(_old_colour);
}

function scrDebugHitboxOverlayDrawGroup(_object,_colour)
{
	if !object_exists(_object)
		return;
	
	with(_object)
	{
		if visible
		{
			var _left = bbox_left;
			var _top = bbox_top;
			var _right = bbox_right;
			var _bottom = bbox_bottom;
			
			draw_set_alpha(0.20);
			draw_set_colour(_colour);
			draw_rectangle(_left,_top,_right,_bottom,false);
			
			draw_set_alpha(0.85);
			draw_rectangle(_left,_top,_right,_bottom,true);
		}
	}
}

function scrDebugHitboxOverlayDrawWhip(_colour)
{
	if !object_exists(objWhip)
		return;
	
	with(objWhip)
	{
		if visible && sprite_exists(sprite_index)
		{
			// Whip sprites use collisionKind=4. The real hit test is the
			// current frame's alpha mask, not the broad resource bbox. Draw the
			// frame-local alpha bounds derived from the source PNG mask data.
			var _bounds = scrWhipSpriteMaskFrameBounds(sprite_index,floor(image_index));
			if !is_undefined(_bounds)
			{
				var _origin_x = sprite_get_xoffset(sprite_index);
				var _origin_y = sprite_get_yoffset(sprite_index);
				var _left = x + ((_bounds.left - _origin_x) * image_xscale);
				var _right = x + ((_bounds.right + 1 - _origin_x) * image_xscale);
				var _top = y + ((_bounds.top - _origin_y) * image_yscale);
				var _bottom = y + ((_bounds.bottom + 1 - _origin_y) * image_yscale);
				var _draw_left = min(_left,_right);
				var _draw_right = max(_left,_right);
				var _draw_top = min(_top,_bottom);
				var _draw_bottom = max(_top,_bottom);
				
				draw_set_alpha(0.20);
				draw_set_colour(_colour);
				draw_rectangle(_draw_left,_draw_top,_draw_right,_draw_bottom,false);
				draw_set_alpha(0.95);
				draw_rectangle(_draw_left,_draw_top,_draw_right,_draw_bottom,true);
			}
		}
	}
}

function scrDebugHitboxOverlayDrawRects(_rects,_colour)
{
	for (var i = 0; i < array_length(_rects); i++)
	{
		var _rect = _rects[i];
		draw_set_alpha(0.25);
		draw_set_colour(_colour);
		draw_rectangle(_rect.left,_rect.top,_rect.right,_rect.bottom,false);
		draw_set_alpha(0.95);
		draw_rectangle(_rect.left,_rect.top,_rect.right,_rect.bottom,true);
	}
}

function scrWhipBackswingHitboxRects()
{
	var _rects = [];
	
	if instance_number(objWhip) <= 0 || instance_number(parPlayer) <= 0
		return _rects;
	
	with(objWhip)
	{
		// Only cover the close/startup areas before the forward whip hitbox extends
		// in front of Simon. Other attack directions keep their sprite masks only.
		if parPlayer.whip_out && aim_dir = FORWARD && floor(image_index) <= 0
		{
			var _player_width = parPlayer.bbox_right - parPlayer.bbox_left + 1;
			var _back_width = max(16,_player_width);
			var _top = parPlayer.bbox_top;
			var _bottom = parPlayer.bbox_bottom;
			
			// Simon's own attack space during the backswing/startup.
			array_push(_rects,{ left: parPlayer.bbox_left, top: _top, right: parPlayer.bbox_right, bottom: _bottom });
			
			if parPlayer.facing >= 0
				array_push(_rects,{ left: parPlayer.bbox_left - _back_width, top: _top, right: parPlayer.bbox_left - 1, bottom: _bottom });
			else
				array_push(_rects,{ left: parPlayer.bbox_right + 1, top: _top, right: parPlayer.bbox_right + _back_width, bottom: _bottom });
		}
	}
	
	return _rects;
}

function scrWhipBackswingHitboxApply()
{
	var _rects = scrWhipBackswingHitboxRects();
	if array_length(_rects) <= 0
		return;
	
	var _enemies = ds_list_create();
	var _hits = ds_list_create();
	for (var i = 0; i < array_length(_rects); i++)
	{
		var _rect = _rects[i];
		ds_list_clear(_hits);
		collision_rectangle_list(_rect.left,_rect.top,_rect.right,_rect.bottom,parEnemy,false,true,_hits,false);
		for (var h = 0; h < ds_list_size(_hits); h++)
		{
			var _enemy = _hits[| h];
			if ds_list_find_index(_enemies,_enemy) < 0
				ds_list_add(_enemies,_enemy);
		}
	}
	ds_list_destroy(_hits);
	
	for (var e = 0; e < ds_list_size(_enemies); e++)
	{
		var _enemy = _enemies[| e];
		if instance_exists(_enemy)
		{
			with(_enemy)
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
						instance_create(other.x,other.y,objItemHeart)
					other.struck = true
				}
				scrEnemyHurt()
			}
		}
	}
	ds_list_destroy(_enemies);
	
	with(parCandle)
	{
		if scrWhipHitboxOverlapSelf(_rects)
		{
			instance_create(x,y,item_id)
			instance_destroy()
		}
	}
	
	scrWhipBackswingHitboxApplyBlock(objBlockNormal,-1,_rects);
	scrWhipBackswingHitboxApplyBlock(objBlockMorningstar,1,_rects);
	scrWhipBackswingHitboxApplyBlock(objBlockFlame,2,_rects);
	scrWhipBackswingHitboxApplyBlock(objBlockIce,3,_rects);
	scrWhipBackswingHitboxApplyBlock(objBlockThunder,4,_rects);
}

function scrWhipBackswingHitboxApplyBlock(_object,_required_flavor,_rects)
{
	with(_object)
	{
		var _can_break = false;
		if _required_flavor < 0
			_can_break = true;
		else if _required_flavor = 1
			_can_break = other.flavor > 0;
		else
			_can_break = other.flavor = _required_flavor;
		
		if _can_break && scrWhipHitboxOverlapSelf(_rects) && !variable_instance_exists(id,"whip_overlap_broken")
		{
			whip_overlap_broken = true;
			bitsound(sndBlockBreak);
			instance_destroy();
		}
	}
}

function scrWhipHitboxOverlapSelf(_rects)
{
	for (var i = 0; i < array_length(_rects); i++)
	{
		var _rect = _rects[i];
		if bbox_right >= _rect.left && bbox_left <= _rect.right && bbox_bottom >= _rect.top && bbox_top <= _rect.bottom
			return true;
	}
	return false;
}


function scrWhipSpriteMaskFrameBounds(_sprite,_frame)
{
	switch(_sprite)
	{
		case sprWhipFlame:
			var _bounds = [{ left: 0, top: 8, right: 7, bottom: 31 }, { left: 0, top: 4, right: 15, bottom: 23 }, { left: 38, top: 8, right: 79, bottom: 15 }, { left: 38, top: 8, right: 79, bottom: 15 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipFlameDown:
			var _bounds = [{ left: 0, top: 16, right: 7, bottom: 39 }, { left: 8, top: 4, right: 23, bottom: 23 }, { left: 25, top: 30, right: 32, bottom: 71 }, { left: 25, top: 30, right: 31, bottom: 71 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipFlameDownDiag:
			var _bounds = [{ left: 0, top: 16, right: 7, bottom: 39 }, { left: 8, top: 4, right: 23, bottom: 23 }, { left: 37, top: 21, right: 69, bottom: 53 }, { left: 37, top: 21, right: 69, bottom: 53 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipFlameUp:
			var _bounds = [{ left: 1, top: 59, right: 7, bottom: 79 }, { left: 16, top: 0, right: 23, bottom: 41 }, { left: 18, top: 0, right: 23, bottom: 41 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipFlameUpDiag:
			var _bounds = [{ left: 1, top: 43, right: 7, bottom: 63 }, { left: 29, top: 2, right: 61, bottom: 34 }, { left: 29, top: 2, right: 61, bottom: 34 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipIce:
			var _bounds = [{ left: 0, top: 8, right: 7, bottom: 31 }, { left: 0, top: 4, right: 15, bottom: 23 }, { left: 38, top: 8, right: 79, bottom: 15 }, { left: 38, top: 8, right: 79, bottom: 15 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipIceDown:
			var _bounds = [{ left: 0, top: 16, right: 7, bottom: 39 }, { left: 8, top: 4, right: 23, bottom: 23 }, { left: 25, top: 30, right: 32, bottom: 71 }, { left: 25, top: 30, right: 31, bottom: 71 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipIceDownDiag:
			var _bounds = [{ left: 0, top: 16, right: 7, bottom: 39 }, { left: 8, top: 4, right: 23, bottom: 23 }, { left: 37, top: 21, right: 69, bottom: 53 }, { left: 37, top: 21, right: 69, bottom: 53 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipIceUp:
			var _bounds = [{ left: 1, top: 59, right: 7, bottom: 79 }, { left: 16, top: 0, right: 23, bottom: 41 }, { left: 18, top: 0, right: 23, bottom: 41 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipIceUpDiag:
			var _bounds = [{ left: 1, top: 43, right: 7, bottom: 63 }, { left: 29, top: 2, right: 61, bottom: 34 }, { left: 29, top: 2, right: 61, bottom: 34 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipLeather:
			var _bounds = [{ left: 0, top: 8, right: 7, bottom: 31 }, { left: 1, top: 5, right: 15, bottom: 22 }, { left: 38, top: 8, right: 63, bottom: 15 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipLeatherDown:
			var _bounds = [{ left: 0, top: 16, right: 7, bottom: 39 }, { left: 9, top: 5, right: 23, bottom: 22 }, { left: 26, top: 30, right: 31, bottom: 55 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipLeatherDownDiag:
			var _bounds = [{ left: 0, top: 16, right: 7, bottom: 39 }, { left: 9, top: 5, right: 23, bottom: 22 }, { left: 39, top: 23, right: 63, bottom: 45 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipLeatherUp:
			var _bounds = [{ left: 0, top: 60, right: 7, bottom: 79 }, { left: 20, top: 16, right: 23, bottom: 41 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipLeatherUpDiag:
			var _bounds = [{ left: 0, top: 44, right: 7, bottom: 63 }, { left: 31, top: 8, right: 53, bottom: 32 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipMorningstar:
			var _bounds = [{ left: 0, top: 8, right: 7, bottom: 31 }, { left: 0, top: 4, right: 15, bottom: 23 }, { left: 38, top: 8, right: 79, bottom: 15 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipMorningstarDown:
			var _bounds = [{ left: 0, top: 16, right: 7, bottom: 39 }, { left: 8, top: 4, right: 23, bottom: 23 }, { left: 25, top: 30, right: 31, bottom: 71 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipMorningstarDownDiag:
			var _bounds = [{ left: 0, top: 16, right: 7, bottom: 39 }, { left: 8, top: 4, right: 23, bottom: 23 }, { left: 37, top: 21, right: 69, bottom: 53 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipMorningstarUp:
			var _bounds = [{ left: 1, top: 59, right: 7, bottom: 79 }, { left: 18, top: 0, right: 23, bottom: 41 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipMorningstarUpDiag:
			var _bounds = [{ left: 1, top: 43, right: 7, bottom: 63 }, { left: 29, top: 2, right: 61, bottom: 34 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipThunder:
			var _bounds = [{ left: 0, top: 8, right: 7, bottom: 31 }, { left: 0, top: 4, right: 15, bottom: 23 }, { left: 38, top: 8, right: 79, bottom: 15 }, { left: 38, top: 8, right: 79, bottom: 15 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipThunderDown:
			var _bounds = [{ left: 0, top: 16, right: 7, bottom: 39 }, { left: 8, top: 4, right: 23, bottom: 23 }, { left: 25, top: 30, right: 32, bottom: 71 }, { left: 25, top: 30, right: 31, bottom: 71 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipThunderDownDiag:
			var _bounds = [{ left: 0, top: 16, right: 7, bottom: 39 }, { left: 8, top: 4, right: 23, bottom: 23 }, { left: 37, top: 21, right: 69, bottom: 53 }, { left: 37, top: 21, right: 69, bottom: 53 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipThunderUp:
			var _bounds = [{ left: 1, top: 59, right: 7, bottom: 79 }, { left: 16, top: 0, right: 23, bottom: 41 }, { left: 18, top: 0, right: 23, bottom: 41 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
		case sprWhipThunderUpDiag:
			var _bounds = [{ left: 1, top: 43, right: 7, bottom: 63 }, { left: 29, top: 2, right: 61, bottom: 34 }, { left: 29, top: 2, right: 61, bottom: 34 }];
			return _bounds[clamp(_frame,0,array_length(_bounds)-1)];
	}
	return undefined;
}
