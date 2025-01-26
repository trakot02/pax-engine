package pax

PRESS_TABLE := [Button_State]Button_State {
    .IDLE    = .PRESS,
    .PRESS   = .ACTIVE,
    .ACTIVE  = .ACTIVE,
    .RELEASE = .PRESS,
}

RELEASE_TABLE := [Button_State]Button_State {
    .IDLE    = .IDLE,
    .PRESS   = .RELEASE,
    .ACTIVE  = .RELEASE,
    .RELEASE = .RELEASE,
}

UPDATE_TABLE := [Button_State]Button_State {
    .IDLE    = .IDLE,
    .PRESS   = .ACTIVE,
    .ACTIVE  = .ACTIVE,
    .RELEASE = .IDLE,
}

TEST_TABLE := [Button_State]bool {
    .IDLE    = false,
    .PRESS   = true,
    .ACTIVE  = true,
    .RELEASE = false,
}

Button_State :: enum
{
    IDLE, PRESS, ACTIVE, RELEASE
}

Mouse_Button :: enum i32
{
    BTN_NONE,
    BTN_LEFT,
    BTN_MIDDLE,
    BTN_RIGHT,
}

Mouse_Event :: struct
{
    slot: int,

    button: Mouse_Button,
    press:  b32,

    wheel: [2]f32,

    position: [2]f32,
    movement: [2]f32,
}

Mouse_State :: struct
{
    slot: int,

    buttons: [Mouse_Button]Button_State,

    wheel: [2]f32,

    position: [2]f32,
    movement: [2]f32,
}

Keyboard_Button :: enum i32
{
    BTN_NONE,

    BTN_ENTER,
    BTN_ESCAPE,

    BTN_A,
    BTN_B,
    BTN_C,
    BTN_D,
    BTN_E,
    BTN_F,
    BTN_G,
    BTN_H,
    BTN_I,
    BTN_J,
    BTN_K,
    BTN_L,
    BTN_M,
    BTN_N,
    BTN_O,
    BTN_P,
    BTN_Q,
    BTN_R,
    BTN_S,
    BTN_T,
    BTN_U,
    BTN_V,
    BTN_W,
    BTN_X,
    BTN_Y,
    BTN_Z,

    BTN_0,
    BTN_1,
    BTN_2,
    BTN_3,
    BTN_4,
    BTN_5,
    BTN_6,
    BTN_7,
    BTN_8,
    BTN_9,
}

Keyboard_Key :: enum i32
{
    KEY_NONE,

    KEY_ENTER,
    KEY_ESCAPE,

    KEY_A,
    KEY_B,
    KEY_C,
    KEY_D,
    KEY_E,
    KEY_F,
    KEY_G,
    KEY_H,
    KEY_I,
    KEY_J,
    KEY_K,
    KEY_L,
    KEY_M,
    KEY_N,
    KEY_O,
    KEY_P,
    KEY_Q,
    KEY_R,
    KEY_S,
    KEY_T,
    KEY_U,
    KEY_V,
    KEY_W,
    KEY_X,
    KEY_Y,
    KEY_Z,

    KEY_0,
    KEY_1,
    KEY_2,
    KEY_3,
    KEY_4,
    KEY_5,
    KEY_6,
    KEY_7,
    KEY_8,
    KEY_9,
}

Keyboard_Event :: struct
{
    slot: int,

    button: Keyboard_Button,
    press:  b32,
}

Keyboard_State :: struct
{
    slot: int,

    buttons: [Keyboard_Button]Button_State,
}

App_Close_Event :: struct {}

Event :: union
{
    App_Close_Event, Mouse_Event, Keyboard_Event,
}

mouse_event :: proc(self: ^Mouse_State, event: Mouse_Event)
{
    if self.slot != event.slot { return }

    press   := PRESS_TABLE[self.buttons[event.button]]
    release := RELEASE_TABLE[self.buttons[event.button]]

    switch event.press {
        case true:  self.buttons[event.button] = press
        case false: self.buttons[event.button] = release
    }

    self.wheel = event.wheel

    self.position = event.position
    self.movement = event.movement
}

mouse_update :: proc(self: ^Mouse_State)
{
    for &button in self.buttons {
        button = UPDATE_TABLE[button]
    }
}

mouse_test_btn :: proc(self: ^Mouse_State, button: Mouse_Button) -> bool
{
    return TEST_TABLE[self.buttons[button]]
}

mouse_get_btn :: proc(self: ^Mouse_State, button: Mouse_Button) -> Button_State
{
    return self.buttons[button]
}

mouse_get_wheel :: proc(self: ^Mouse_State) -> [2]f32
{
    return self.wheel
}

mouse_get_position :: proc(self: ^Mouse_State) -> [2]f32
{
    return self.position
}

mouse_get_movement :: proc(self: ^Mouse_State) -> [2]f32
{
    return self.movement
}

keyboard_event :: proc(self: ^Keyboard_State, event: Keyboard_Event)
{
    if self.slot != event.slot { return }

    press   := PRESS_TABLE[self.buttons[event.button]]
    release := RELEASE_TABLE[self.buttons[event.button]]

    switch event.press {
        case true:  self.buttons[event.button] = press
        case false: self.buttons[event.button] = release
    }
}

keyboard_update :: proc(self: ^Keyboard_State)
{
    for &button in self.buttons {
        button = UPDATE_TABLE[button]
    }
}

keyboard_test_btn :: proc(self: ^Keyboard_State, button: Keyboard_Button) -> bool
{
    return TEST_TABLE[self.buttons[button]]
}

keyboard_test_key :: proc(self: ^Keyboard_State, key: Keyboard_Key) -> bool
{
    return keyboard_test_btn(self, keyboard_key_to_button(key))
}

keyboard_get_btn :: proc(self: ^Keyboard_State, button: Keyboard_Button) -> Button_State
{
    return self.buttons[button]
}

keyboard_get_key :: proc(self: ^Keyboard_State, key: Keyboard_Key) -> Button_State
{
    return keyboard_get_btn(self, keyboard_key_to_button(key))
}
