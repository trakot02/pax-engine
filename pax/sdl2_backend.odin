package pax

import "core:log"
import "core:strings"
import "core:mem"

import sdl "vendor:sdl2"
import gl  "vendor:OpenGL"

//
// Variables
//

SDL2_BUTTON_PRESS := [2]b32 {
    sdl.PRESSED  = true,
    sdl.RELEASED = false,
}

SDL2_MOUSE_BUTTON := [4]Mouse_Button {
    sdl.BUTTON_LEFT   = .BTN_LEFT,
    sdl.BUTTON_MIDDLE = .BTN_MIDDLE,
    sdl.BUTTON_RIGHT  = .BTN_RIGHT,
}

SDL2_KEYBOARD_BUTTON := [512]Keyboard_Button {
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

    .BTN_ENTER  = .RETURN,
    .BTN_ESCAPE = .ESCAPE,

    .BTN_A = .A,
    .BTN_B = .B,
    .BTN_C = .C,
    .BTN_D = .D,
    .BTN_E = .E,
    .BTN_F = .F,
    .BTN_G = .G,
    .BTN_H = .H,
    .BTN_I = .I,
    .BTN_J = .J,
    .BTN_K = .K,
    .BTN_L = .L,
    .BTN_M = .M,
    .BTN_N = .N,
    .BTN_O = .O,
    .BTN_P = .P,
    .BTN_Q = .Q,
    .BTN_R = .R,
    .BTN_S = .S,
    .BTN_T = .T,
    .BTN_U = .U,
    .BTN_V = .V,
    .BTN_W = .W,
    .BTN_X = .X,
    .BTN_Y = .Y,
    .BTN_Z = .Z,

    .BTN_0 = .NUM0,
    .BTN_1 = .NUM1,
    .BTN_2 = .NUM2,
    .BTN_3 = .NUM3,
    .BTN_4 = .NUM4,
    .BTN_5 = .NUM5,
    .BTN_6 = .NUM6,
    .BTN_7 = .NUM7,
    .BTN_8 = .NUM8,
    .BTN_9 = .NUM9,
}

SDL2_KEYBOARD_KEY_TO_KEYCODE := [Keyboard_Key]sdl.Keycode {
    .KEY_NONE = sdl.Keycode(0),

    .KEY_ENTER  = .RETURN,
    .KEY_ESCAPE = .ESCAPE,

    .KEY_A = .A,
    .KEY_B = .B,
    .KEY_C = .C,
    .KEY_D = .D,
    .KEY_E = .E,
    .KEY_F = .F,
    .KEY_G = .G,
    .KEY_H = .H,
    .KEY_I = .I,
    .KEY_J = .J,
    .KEY_K = .K,
    .KEY_L = .L,
    .KEY_M = .M,
    .KEY_N = .N,
    .KEY_O = .O,
    .KEY_P = .P,
    .KEY_Q = .Q,
    .KEY_R = .R,
    .KEY_S = .S,
    .KEY_T = .T,
    .KEY_U = .U,
    .KEY_V = .V,
    .KEY_W = .W,
    .KEY_X = .X,
    .KEY_Y = .Y,
    .KEY_Z = .Z,

    .KEY_0 = .NUM0,
    .KEY_1 = .NUM1,
    .KEY_2 = .NUM2,
    .KEY_3 = .NUM3,
    .KEY_4 = .NUM4,
    .KEY_5 = .NUM5,
    .KEY_6 = .NUM6,
    .KEY_7 = .NUM7,
    .KEY_8 = .NUM8,
    .KEY_9 = .NUM9,
}

sdl2_main_window := sdl2_Window {}

//
// Definitions
//

sdl2_Window :: struct
{
    value: ^sdl.Window,
    glctx: sdl.GLContext,
}

//
// Functions
//

sdl2_backend_init :: proc(dimension: [2]int, title: string) -> bool
{
    sdl.Init(sdl.INIT_VIDEO)

    window, state := sdl2_window_init(dimension, title)

    if state == false {
        sdl.Quit()

        return false
    }

    sdl2_main_window = window

    return true
}

sdl2_backend_destroy :: proc()
{
    sdl2_window_destroy(&sdl2_main_window)

    sdl.Quit()
}

sdl2_keyboard_key_to_button :: proc(key: Keyboard_Key) -> Keyboard_Button
{
    keycode  := SDL2_KEYBOARD_KEY_TO_KEYCODE[key]
    scancode := sdl.GetScancodeFromKey(keycode)

    return SDL2_KEYBOARD_BUTTON[scancode]
}

sdl2_poll_event :: proc() -> Event
{
    event := sdl.Event {}

    if sdl.PollEvent(&event) == false { return nil }

    #partial switch event.type {
        case .QUIT: return App_Close_Event {}

        case .MOUSEMOTION:     return sdl2_mouse_motion_to_event(event.motion)
        case .MOUSEWHEEL:      return sdl2_mouse_wheel_to_event(event.wheel)
        case .MOUSEBUTTONDOWN: return sdl2_mouse_button_to_event(event.button)
        case .MOUSEBUTTONUP:   return sdl2_mouse_button_to_event(event.button)

        case .KEYDOWN: return sdl2_keyboard_button_to_event(event.key)
        case .KEYUP:   return sdl2_keyboard_button_to_event(event.key)

        case .WINDOWEVENT: {
            #partial switch event.window.event {
                case .RESIZED: return sdl2_window_resize_to_event(event.window)
            }
        }
    }

    return nil
}

sdl2_mouse_motion_to_event :: proc(motion: sdl.MouseMotionEvent) -> Mouse_Event
{
    return Mouse_Event {
        ident = int(motion.which),

        position = {f32(motion.x),    f32(motion.y)},
        movement = {f32(motion.xrel), f32(motion.yrel)},
    }
}

sdl2_mouse_wheel_to_event :: proc(wheel: sdl.MouseWheelEvent) -> Mouse_Event
{
    return Mouse_Event {
        ident = int(wheel.which),

        wheel = {f32(wheel.x), f32(wheel.y)},
    }
}

sdl2_mouse_button_to_event :: proc(button: sdl.MouseButtonEvent) -> Mouse_Event
{
    return Mouse_Event {
        ident = int(button.which),

        button = SDL2_MOUSE_BUTTON[button.button],
        press  = SDL2_BUTTON_PRESS[button.state],
    }
}

sdl2_keyboard_button_to_event :: proc(button: sdl.KeyboardEvent) -> Keyboard_Event
{
    return Keyboard_Event {
        ident = 0,

        button = SDL2_KEYBOARD_BUTTON[button.keysym.scancode],
        press  = SDL2_BUTTON_PRESS[button.state],
    }
}

sdl2_window_resize_to_event :: proc(window: sdl.WindowEvent) -> Window_Resize_Event
{
    return Window_Resize_Event {
        ident = int(window.windowID),

        dimension = {int(window.data1), int(window.data2)},
    }
}

sdl2_window_main :: proc() -> ^sdl2_Window
{
    return &sdl2_main_window
}

sdl2_window_init :: proc(dimension: [2]int, title: string) -> (sdl2_Window, bool)
{
    window := sdl2_Window {}

    clone, error := strings.clone_to_cstring(title,
        context.temp_allocator)

    if error != nil {
        log.errorf("Window: Unable to clone title to c-string")

        return {}, false
    }

    defer mem.free_all(context.temp_allocator)

    place  := i32(sdl.WINDOWPOS_CENTERED)
    width  := i32(dimension.x)
    height := i32(dimension.y)
    flags  := sdl.WindowFlags {.OPENGL, .HIDDEN, .RESIZABLE}

    window.value = sdl.CreateWindow(clone, place, place, width, height, flags)

    if window.value != nil {
        sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, 3)
        sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, 3)
        sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK, i32(sdl.GLprofile.CORE))
        sdl.GL_SetAttribute(.DOUBLEBUFFER, 1)

        sdl.GL_SetAttribute(.MULTISAMPLEBUFFERS, 1)
        sdl.GL_SetAttribute(.MULTISAMPLESAMPLES, 4)

        window.glctx = sdl.GL_CreateContext(window.value)

        if sdl.GL_MakeCurrent(window.value, window.glctx) == 0 {
            gl.load_up_to(3, 3, sdl.gl_set_proc_address)

            return window, true
        }

        sdl.DestroyWindow(window.value)
    }

    return {}, false
}

sdl2_window_destroy :: proc(self: ^sdl2_Window)
{
    sdl.DestroyWindow(self.value)
}

sdl2_window_swap_buffers :: proc(self: ^sdl2_Window)
{
    sdl.GL_SwapWindow(self.value)
}

sdl2_window_show :: proc(self: ^sdl2_Window)
{
    sdl.ShowWindow(self.value)
}

sdl2_window_hide :: proc(self: ^sdl2_Window)
{
    sdl.HideWindow(self.value)
}

sdl2_window_get_title :: proc(self: ^sdl2_Window) -> string
{
    return ""
}

sdl2_window_get_flags :: proc(self: ^sdl2_Window)
{}

sdl2_window_get_rect :: proc(self: ^sdl2_Window) -> [4]int
{
    left   := i32(0)
    top    := i32(0)
    width  := i32(0)
    height := i32(0)

    sdl.GetWindowPosition(self.value, &left, &top)
    sdl.GetWindowSize(self.value, &width, &height)

    return {int(left), int(top), int(width), int(height)}
}

sdl2_window_get_position :: proc(self: ^sdl2_Window) -> [2]int
{
    left := i32(0)
    top  := i32(0)

    sdl.GetWindowPosition(self.value, &left, &top)

    return {int(left), int(top)}
}

sdl2_window_get_dimension :: proc(self: ^sdl2_Window) -> [2]int
{
    width  := i32(0)
    height := i32(0)

    sdl.GetWindowSize(self.value, &width, &height)

    return {int(width), int(height)}
}

sdl2_window_set_title :: proc(self: ^sdl2_Window, title: string)
{
    clone, error := strings.clone_to_cstring(title,
        context.temp_allocator)

    if error != nil {
        log.errorf("Window: ")

        return
    }

    defer mem.free_all(context.temp_allocator)

    sdl.SetWindowTitle(self.value, clone)
}

sdl2_window_set_flags :: proc(self: ^sdl2_Window, flags: int)
{}

sdl2_window_set_rect :: proc(self: ^sdl2_Window, rect: [4]int)
{
    left   := i32(rect.x)
    top    := i32(rect.y)
    width  := i32(rect.z)
    height := i32(rect.w)

    sdl.SetWindowPosition(self.value, left, top)
    sdl.SetWindowSize(self.value, width, height)
}

sdl2_window_set_position :: proc(self: ^sdl2_Window, position: [2]int)
{
    top  := i32(position.x)
    left := i32(position.y)

    sdl.SetWindowPosition(self.value, top, left)
}

sdl2_window_set_dimension :: proc(self: ^sdl2_Window, dimension: [2]int)
{
    width  := i32(dimension.x)
    height := i32(dimension.y)

    sdl.SetWindowSize(self.value, width, height)
}
