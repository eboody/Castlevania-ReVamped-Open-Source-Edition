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