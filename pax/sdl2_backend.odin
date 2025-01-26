package pax

import "core:log"
import "core:strings"
import "core:mem"

import sdl "vendor:sdl2"

SDL2_BUTTON_PRESS := [2]b32 {
    sdl.PRESSED  = true,
    sdl.RELEASED = false,
}

SDL2_MOUSE_BUTTON := [4]Mouse_Button {
    sdl.BUTTON_LEFT   = Mouse_Button.BTN_LEFT,
    sdl.BUTTON_MIDDLE = Mouse_Button.BTN_MIDDLE,
    sdl.BUTTON_RIGHT  = Mouse_Button.BTN_RIGHT,
}

SDL2_SCANCODE_TO_KEYBOARD_BUTTON := [512]Keyboard_Button {
    sdl.Scancode.RETURN = .BTN_ENTER,
    sdl.Scancode.ESCAPE = .BTN_ESCAPE,

    sdl.Scancode.A = .BTN_A,
    sdl.Scancode.B = .BTN_B,
    sdl.Scancode.C = .BTN_C,
    sdl.Scancode.D = .BTN_D,
    sdl.Scancode.E = .BTN_E,
    sdl.Scancode.F = .BTN_F,
    sdl.Scancode.G = .BTN_G,
    sdl.Scancode.H = .BTN_H,
    sdl.Scancode.I = .BTN_I,
    sdl.Scancode.J = .BTN_J,
    sdl.Scancode.K = .BTN_K,
    sdl.Scancode.L = .BTN_L,
    sdl.Scancode.M = .BTN_M,
    sdl.Scancode.N = .BTN_N,
    sdl.Scancode.O = .BTN_O,
    sdl.Scancode.P = .BTN_P,
    sdl.Scancode.Q = .BTN_Q,
    sdl.Scancode.R = .BTN_R,
    sdl.Scancode.S = .BTN_S,
    sdl.Scancode.T = .BTN_T,
    sdl.Scancode.U = .BTN_U,
    sdl.Scancode.V = .BTN_V,
    sdl.Scancode.W = .BTN_W,
    sdl.Scancode.X = .BTN_X,
    sdl.Scancode.Y = .BTN_Y,
    sdl.Scancode.Z = .BTN_Z,

    sdl.Scancode.NUM0 = .BTN_0,
    sdl.Scancode.NUM1 = .BTN_1,
    sdl.Scancode.NUM2 = .BTN_2,
    sdl.Scancode.NUM3 = .BTN_3,
    sdl.Scancode.NUM4 = .BTN_4,
    sdl.Scancode.NUM5 = .BTN_5,
    sdl.Scancode.NUM6 = .BTN_6,
    sdl.Scancode.NUM7 = .BTN_7,
    sdl.Scancode.NUM8 = .BTN_8,
    sdl.Scancode.NUM9 = .BTN_9,
}

SDL2_KEYBOARD_BUTTON_TO_SCANCODE := [Keyboard_Button]sdl.Scancode {
    .BTN_NONE = sdl.Scancode(0),

    .BTN_ENTER  = sdl.Scancode.RETURN,
    .BTN_ESCAPE = sdl.Scancode.ESCAPE,

    .BTN_A = sdl.Scancode.A,
    .BTN_B = sdl.Scancode.B,
    .BTN_C = sdl.Scancode.C,
    .BTN_D = sdl.Scancode.D,
    .BTN_E = sdl.Scancode.E,
    .BTN_F = sdl.Scancode.F,
    .BTN_G = sdl.Scancode.G,
    .BTN_H = sdl.Scancode.H,
    .BTN_I = sdl.Scancode.I,
    .BTN_J = sdl.Scancode.J,
    .BTN_K = sdl.Scancode.K,
    .BTN_L = sdl.Scancode.L,
    .BTN_M = sdl.Scancode.M,
    .BTN_N = sdl.Scancode.N,
    .BTN_O = sdl.Scancode.O,
    .BTN_P = sdl.Scancode.P,
    .BTN_Q = sdl.Scancode.Q,
    .BTN_R = sdl.Scancode.R,
    .BTN_S = sdl.Scancode.S,
    .BTN_T = sdl.Scancode.T,
    .BTN_U = sdl.Scancode.U,
    .BTN_V = sdl.Scancode.V,
    .BTN_W = sdl.Scancode.W,
    .BTN_X = sdl.Scancode.X,
    .BTN_Y = sdl.Scancode.Y,
    .BTN_Z = sdl.Scancode.Z,

    .BTN_0 = sdl.Scancode.NUM0,
    .BTN_1 = sdl.Scancode.NUM1,
    .BTN_2 = sdl.Scancode.NUM2,
    .BTN_3 = sdl.Scancode.NUM3,
    .BTN_4 = sdl.Scancode.NUM4,
    .BTN_5 = sdl.Scancode.NUM5,
    .BTN_6 = sdl.Scancode.NUM6,
    .BTN_7 = sdl.Scancode.NUM7,
    .BTN_8 = sdl.Scancode.NUM8,
    .BTN_9 = sdl.Scancode.NUM9,
}

SDL2_KEYBOARD_KEY_TO_KEYCODE := [Keyboard_Key]sdl.Keycode {
    .KEY_NONE = sdl.Keycode(0),

    .KEY_ENTER  = sdl.Keycode.RETURN,
    .KEY_ESCAPE = sdl.Keycode.ESCAPE,

    .KEY_A = sdl.Keycode.A,
    .KEY_B = sdl.Keycode.B,
    .KEY_C = sdl.Keycode.C,
    .KEY_D = sdl.Keycode.D,
    .KEY_E = sdl.Keycode.E,
    .KEY_F = sdl.Keycode.F,
    .KEY_G = sdl.Keycode.G,
    .KEY_H = sdl.Keycode.H,
    .KEY_I = sdl.Keycode.I,
    .KEY_J = sdl.Keycode.J,
    .KEY_K = sdl.Keycode.K,
    .KEY_L = sdl.Keycode.L,
    .KEY_M = sdl.Keycode.M,
    .KEY_N = sdl.Keycode.N,
    .KEY_O = sdl.Keycode.O,
    .KEY_P = sdl.Keycode.P,
    .KEY_Q = sdl.Keycode.Q,
    .KEY_R = sdl.Keycode.R,
    .KEY_S = sdl.Keycode.S,
    .KEY_T = sdl.Keycode.T,
    .KEY_U = sdl.Keycode.U,
    .KEY_V = sdl.Keycode.V,
    .KEY_W = sdl.Keycode.W,
    .KEY_X = sdl.Keycode.X,
    .KEY_Y = sdl.Keycode.Y,
    .KEY_Z = sdl.Keycode.Z,

    .KEY_0 = sdl.Keycode.NUM0,
    .KEY_1 = sdl.Keycode.NUM1,
    .KEY_2 = sdl.Keycode.NUM2,
    .KEY_3 = sdl.Keycode.NUM3,
    .KEY_4 = sdl.Keycode.NUM4,
    .KEY_5 = sdl.Keycode.NUM5,
    .KEY_6 = sdl.Keycode.NUM6,
    .KEY_7 = sdl.Keycode.NUM7,
    .KEY_8 = sdl.Keycode.NUM8,
    .KEY_9 = sdl.Keycode.NUM9,
}

sdl2_backend_init :: proc()
{
    sdl.Init(sdl.INIT_VIDEO)
}

sdl2_backend_destroy :: proc()
{
    sdl.Quit()
}

sdl2_poll_event :: proc() -> Event
{
    event := sdl.Event {}

    if sdl.PollEvent(&event) {
        #partial switch event.type {
            case .QUIT: return App_Close_Event {}

            case .MOUSEMOTION:     return sdl2_mouse_motion_to_event(event.motion)
            case .MOUSEWHEEL:      return sdl2_mouse_wheel_to_event(event.wheel)
            case .MOUSEBUTTONDOWN: return sdl2_mouse_button_to_event(event.button)
            case .MOUSEBUTTONUP:   return sdl2_mouse_button_to_event(event.button)

            case .KEYDOWN: return sdl2_keyboard_button_to_event(event.key)
            case .KEYUP:   return sdl2_keyboard_button_to_event(event.key)
        }
    }

    return nil
}

sdl2_mouse_motion_to_event :: proc(motion: sdl.MouseMotionEvent) -> Mouse_Event
{
    value := Mouse_Event {}
    point := [2]i32 {}

    value.slot = int(motion.which)

    sdl.GetMouseState(&point[0], &point[1])

    value.position = {f32(point.x),     f32(point.y)}
    value.movement = {f32(motion.xrel), f32(motion.yrel)}

    return value
}

sdl2_mouse_wheel_to_event :: proc(wheel: sdl.MouseWheelEvent) -> Mouse_Event
{
    value := Mouse_Event {}
    point := [2]i32 {}

    value.slot = int(wheel.which)

    sdl.GetMouseState(&point[0], &point[1])

    value.wheel    = {f32(wheel.x), f32(wheel.y)}
    value.position = {f32(point.x), f32(point.y)}

    return value
}

sdl2_mouse_button_to_event :: proc(button: sdl.MouseButtonEvent) -> Mouse_Event
{
    value := Mouse_Event {}
    point := [2]i32 {}

    value.slot = int(button.which)

    sdl.GetMouseState(&point[0], &point[1])

    value.button = SDL2_MOUSE_BUTTON[button.button]
    value.press  = SDL2_BUTTON_PRESS[button.state]

    value.position = {f32(point.x), f32(point.y)}

    return value
}

sdl2_keyboard_button_to_event :: proc(button: sdl.KeyboardEvent) -> Keyboard_Event
{
    value := Keyboard_Event {}

    value.slot   = int(0)
    value.button = SDL2_SCANCODE_TO_KEYBOARD_BUTTON[button.keysym.scancode]
    value.press  = SDL2_BUTTON_PRESS[button.state]

    return value
}

sdl2_keyboard_key_to_button :: proc(key: Keyboard_Key) -> Keyboard_Button
{
    keycode  := SDL2_KEYBOARD_KEY_TO_KEYCODE[key]
    scancode := sdl.GetScancodeFromKey(keycode)

    return SDL2_SCANCODE_TO_KEYBOARD_BUTTON[scancode]
}

sdl2_Window_Handle :: rawptr

sdl2_window_init :: proc(size: [2]int, title: string) -> sdl2_Window_Handle
{
    width  := i32(size.x)
    height := i32(size.y)

    clone, error := strings.clone_to_cstring(title,
        context.temp_allocator)

    if error != nil {
        log.errorf("Window: Unable to clone title to c-string")

        return nil
    }

    defer mem.free_all(context.temp_allocator)

    window := sdl.CreateWindow(clone, sdl.WINDOWPOS_CENTERED,
        sdl.WINDOWPOS_CENTERED, width, height, {})

    return window
}

sdl2_window_destroy :: proc(self: ^sdl2_Window_Handle)
{
    sdl.DestroyWindow(cast(^sdl.Window) (self))
}

sdl2_window_size :: proc(self: ^sdl2_Window_Handle) -> [2]int
{
    width  := i32(0)
    height := i32(0)

    sdl.GetWindowSize(cast (^sdl.Window) (self), &width, &height)

    return {int(width), int(height)}
}
