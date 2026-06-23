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