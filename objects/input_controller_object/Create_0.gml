if (instance_number(object_index) > 1)
{
    __input_error("More than one instance of ", object_get_name(object_index), " has been created\nPlease ensure that ", object_get_name(object_index), " is never manually created");
    instance_destroy();
    return;
}

mobile_virtual_controls_enabled = (os_type == os_android);
mobile_virtual_controls_hidden = false;
mobile_virtual_controls = [];

if (mobile_virtual_controls_enabled)
{
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    var _margin = 24;
    var _pad_radius = 88;
    var _button_radius = 42;
    var _small_radius = 30;
    var _right_x = _gui_w - _margin - _button_radius;
    var _bottom_y = _gui_h - _margin - _button_radius;

    array_push(mobile_virtual_controls,
        input_virtual_create()
            .circle(_margin + _pad_radius, _gui_h - _margin - _pad_radius, _pad_radius)
            .dpad(undefined, "left", "right", "up", "down", false)
            .threshold(24, 72)
            .priority(20));

    array_push(mobile_virtual_controls,
        input_virtual_create()
            .circle(_right_x, _bottom_y, _button_radius)
            .button("attack")
            .priority(30));

    array_push(mobile_virtual_controls,
        input_virtual_create()
            .circle(_right_x - 92, _bottom_y - 16, _button_radius)
            .button("jump")
            .priority(30));

    array_push(mobile_virtual_controls,
        input_virtual_create()
            .circle(_right_x, _bottom_y - 92, _button_radius)
            .button("subweapon")
            .priority(30));

    array_push(mobile_virtual_controls,
        input_virtual_create()
            .circle(_right_x - 92, _bottom_y - 108, _button_radius)
            .button("dash")
            .priority(30));

    array_push(mobile_virtual_controls,
        input_virtual_create()
            .circle(_right_x - 184, _bottom_y - 58, _small_radius)
            .button("aimlock")
            .priority(25));

    array_push(mobile_virtual_controls,
        input_virtual_create()
            .circle(_right_x - 184, _bottom_y - 128, _small_radius)
            .button("swap")
            .priority(25));

    array_push(mobile_virtual_controls,
        input_virtual_create()
            .circle(_gui_w - _margin - _small_radius, _margin + _small_radius, _small_radius)
            .button("pause")
            .priority(25));

    array_push(mobile_virtual_controls,
        input_virtual_create()
            .circle(_gui_w - _margin - (3 * _small_radius), _margin + _small_radius, _small_radius)
            .button("map")
            .priority(25));
}