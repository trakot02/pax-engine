package pax

import "core:log"
import "core:strings"
import "core:mem"

import sdl "vendor:sdl2"

Window :: struct
{
    //
    //
    //
    data: rawptr,

    //
    //
    //
    close: Signal(Empty_Event),
}

//
//
//
window_init :: proc(self: ^Window, size: [2]f32, allocator := context.allocator) -> bool
{
    flags := sdl.WindowFlags {.HIDDEN}

    self.data = auto_cast sdl.CreateWindow("",
        128, 128, i32(size.x), i32(size.y), flags)

    if self.data == nil {
        log.errorf("SDL: %v", sdl.GetErrorString())

        return false
    }

    return true
}

//
//
//
window_destroy :: proc(self: ^Window)
{
    sdl.DestroyWindow(auto_cast self.data)

    self.data = nil
}

//
//
//
window_show :: proc(self: ^Window)
{
    sdl.ShowWindow(auto_cast self.data)
}

//
//
//
window_hide :: proc(self: ^Window)
{
    sdl.HideWindow(auto_cast self.data)
}

//
//
//
window_set_title :: proc(self: ^Window, name: string) -> bool
{
    alloc := context.temp_allocator

    clone, error := strings.clone_to_cstring(name, alloc)

    if error != nil {
        log.errorf("Window: Unable to clone %q to c-string",
            name)

        return false
    }

    sdl.SetWindowTitle(auto_cast self.data, clone)

    mem.free_all(alloc)

    return true
}

//
//
//
window_set_border :: proc(self: ^Window, border: bool)
{
    sdl.SetWindowBordered(auto_cast self.data,
        sdl.bool(border))
}

//
//
//
window_set_size :: proc(self: ^Window, size: [2]f32)
{
    sdl.SetWindowSize(auto_cast self.data,
        i32(size.x), i32(size.y))
}

//
//
//
window_set_origin :: proc(self: ^Window, origin: [2]f32)
{
    sdl.SetWindowPosition(auto_cast self.data,
        i32(origin.x), i32(origin.y))
}

//
//
//
window_emit :: proc(self: ^Window, event: sdl.Event)
{
    #partial switch event.type {
        case .QUIT: signal_emit(&self.close)
    }
}
