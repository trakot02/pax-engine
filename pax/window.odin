package pax

import "core:log"
import "core:strings"
import "core:mem"

import sdl "vendor:sdl2"

Window :: struct
{
    window:   ^sdl.Window,
    renderer: ^sdl.Renderer,

    close: Signal(Empty_Event),
}

window_init :: proc(self: ^Window, title: string, size: [2]f32, allocator := context.allocator) -> bool
{
    temp        := context.temp_allocator
    cstr, error := strings.clone_to_cstring(title, temp)

    if error != nil {
        log.errorf("Unable to create temporary string\n")

        return false
    }

    flags := sdl.WindowFlags {.HIDDEN}

    self.window = sdl.CreateWindow(cstr, 100, 100,
        i32(size.x), i32(size.y), flags)

    mem.delete(cstr, temp)

    if self.window == nil {
        log.errorf("SDL: %v\n",
            sdl.GetErrorString())

        return false
    }

    self.renderer = sdl.CreateRenderer(self.window, -1, {.ACCELERATED})

    if self.renderer == nil {
        log.errorf("SDL: %v\n",
            sdl.GetErrorString())

        return false
    }

    return true
}

window_destroy :: proc(self: ^Window)
{
    sdl.DestroyRenderer(self.renderer)
    sdl.DestroyWindow(self.window)
}

window_show :: proc(self: ^Window)
{
    sdl.ShowWindow(self.window)
}

window_hide :: proc(self: ^Window)
{
    sdl.HideWindow(self.window)
}

window_resize :: proc(self: ^Window, size: [2]f32)
{
    sdl.SetWindowSize(self.window, i32(size.x), i32(size.y))
}

window_emit :: proc(self: ^Window, event: sdl.Event)
{
    #partial switch event.type {
        case .QUIT: signal_emit(&self.close)
    }
}
