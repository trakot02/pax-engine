package pax

//
// Definitions
//

App_Close_Event :: struct {}

Mouse_Event :: struct
{
    ident:    int,
    button:   Mouse_Button,
    press:    b32,
    wheel:    [2]f32,
    position: [2]f32,
    movement: [2]f32,
}

Keyboard_Event :: struct
{
    ident:  int,
    button: Keyboard_Button,
    press:  b32,
}

Window_Resize_Event :: struct
{
    ident:     int,
    dimension: [2]int,
}

Event :: union
{
    App_Close_Event,
    Mouse_Event,
    Keyboard_Event,
    Window_Resize_Event,
}
