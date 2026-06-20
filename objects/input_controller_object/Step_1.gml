if (os_type == os_android)
{
    android_gamepad_enumerate_counter += 1;
    if (android_gamepad_enumerate_counter >= 60)
    {
        android_gamepad_enumerate_counter = 0;
        gamepad_enumerate();
    }
}

__input_system_tick();

if (!variable_global_exists("debug_hitbox_overlay"))
    global.debug_hitbox_overlay = false;

if (!variable_global_exists("debug_hitbox_toggle_suppress"))
    global.debug_hitbox_toggle_suppress = 0;

if (!variable_global_exists("debug_hitbox_toggle_notice"))
    global.debug_hitbox_toggle_notice = 0;

if (global.debug_hitbox_toggle_suppress > 0)
    global.debug_hitbox_toggle_suppress -= 1;

if (global.debug_hitbox_toggle_notice > 0)
    global.debug_hitbox_toggle_notice -= 1;

var _debug_hitbox_toggle = (input_check("aimlock") && input_check_pressed("map")) || keyboard_check_pressed(ord("H"));
if (_debug_hitbox_toggle)
{
    global.debug_hitbox_overlay = !global.debug_hitbox_overlay;
    if variable_global_exists("options")
        ds_map_replace(global.options,"debug_hitbox_overlay",global.debug_hitbox_overlay);
    global.debug_hitbox_toggle_suppress = 3;
    global.debug_hitbox_toggle_notice = 90;
    input_verb_consume(["map", "aimlock"]);
}

if (mobile_virtual_controls_enabled)
{
    var _hide_virtual_controls = input_gamepad_is_any_connected();

    if (_hide_virtual_controls != mobile_virtual_controls_hidden)
    {
        mobile_virtual_controls_hidden = _hide_virtual_controls;

        var _i = 0;
        repeat(array_length(mobile_virtual_controls))
        {
            mobile_virtual_controls[_i].active(!mobile_virtual_controls_hidden);
            ++_i;
        }
    }
}