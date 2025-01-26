package pax

Mouse_Event :: struct
{
    slot: int,

    button: Mouse_Button,
    press:  b32,

    wheel: [2]f32,

    position: [2]f32,
    movement: [2]f32,
}

Keyboard_Event :: struct
{
    slot: int,

    button: Keyboard_Button,
    press:  b32,
}

App_Close_Event :: struct {}

Event :: union
{
    App_Close_Event, Mouse_Event, Keyboard_Event,
}
