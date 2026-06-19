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