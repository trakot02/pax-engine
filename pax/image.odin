package pax

import "core:strings"
import "core:mem"
import "core:log"

import sdl  "vendor:sdl2"
import sdli "vendor:sdl2/image"

Image :: struct
{
    //
    //
    //
    data: rawptr,
}

Image_Context :: struct
{
    //
    //
    //
    renderer: ^Renderer,
}

//
//
//
image_clear :: proc(self: ^Image_Context, value: ^Image)
{
    sdl.DestroyTexture(auto_cast value.data)
}

//
//
//
image_read :: proc(self: ^Image_Context, name: string) -> (Image, bool)
{
    alloc := context.temp_allocator
    value := Image {}

    clone, error := strings.clone_to_cstring(name, alloc)

    if error != nil {
        log.errorf("Image: Unable to open %q for reading",
            name)

        return {}, false
    }

    value.data = sdli.LoadTexture(auto_cast self.renderer.data, clone)

    mem.free_all(alloc)

    if value.data == nil {
        log.errorf("SDL: %v", sdl.GetErrorString())

        return {}, false
    }

    return value, true
}

//
// todo (trakot02): In the future.
//
// image_write :: proc(self: ^Image_Context, name: string, value: ^Image) -> bool
// {
//     return false
// }

//
//
//
image_registry :: proc(self: ^Image_Context) -> Registry(Image)
{
    value := Registry(Image) {}

    value.instance   = auto_cast self
    value.clear_proc = auto_cast image_clear
    value.read_proc  = auto_cast image_read
    // value.write_proc = auto_cast image_write

    return value
}
