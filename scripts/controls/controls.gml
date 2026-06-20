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
		kMap = false;

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
		scrDebugHitboxOverlayDrawGroup(parPlayer,c_lime,"SIMON");
		scrDebugHitboxOverlayDrawGroup(objWhip,c_aqua,"WHIP");
		scrDebugHitboxOverlayDrawGroup(parEnemy,c_red,"ENEMY");
		scrDebugHitboxOverlayDrawGroup(parCandle,c_yellow,"BREAKABLE");
		scrDebugHitboxOverlayDrawGroup(objBlockNormal,c_orange,"BREAKABLE");
		scrDebugHitboxOverlayDrawGroup(objBlockMorningstar,c_orange,"BREAKABLE");
		scrDebugHitboxOverlayDrawGroup(objBlockFlame,c_orange,"BREAKABLE");
		scrDebugHitboxOverlayDrawGroup(objBlockIce,c_orange,"BREAKABLE");
		scrDebugHitboxOverlayDrawGroup(objBlockThunder,c_orange,"BREAKABLE");
		scrDebugHitboxOverlayDrawGroup(objBlockPound,c_orange,"BREAKABLE");
		scrDebugHitboxOverlayDrawGroup(objBlockSlide,c_orange,"BREAKABLE");
		
		draw_set_alpha(1);
		draw_set_colour(c_white);
		draw_text_outline(xview + 4,yview + hview - 18,c_black,c_white,"Hitboxes: ON (Aimlock+Map / H)");
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

function scrDebugHitboxOverlayDrawGroup(_object,_colour,_label)
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
			draw_line(_left,_top,_right,_bottom);
			draw_line(_right,_top,_left,_bottom);
			
			draw_set_alpha(1);
			draw_text_outline(_left,_top - 8,c_black,_colour,_label);
		}
	}
}