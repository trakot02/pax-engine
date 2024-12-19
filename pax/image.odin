package pax

import "core:mem"
import "core:log"
import "core:strings"

import sdl  "vendor:sdl2"
import sdli "vendor:sdl2/image"

Image :: struct
{
    data: ^sdl.Texture,
}

Image_Reader :: struct
{
    renderer: ^sdl.Renderer,
}

image_read :: proc(self: ^Image_Reader, name: string) -> (Image, bool)
{
    temp  := context.temp_allocator
    value := Image {}

    cstr, error := strings.clone_to_cstring(name, temp)

    if error != nil {
        log.errorf("Unable to open %q for reading\n",
            name)

        return {}, false
    }

    value.data = sdli.LoadTexture(self.renderer, cstr)

    mem.free_all(temp)

    if value.data == nil {
        log.errorf("SDL: %v", sdl.GetErrorString())

        return {}, false
    }

    return value, true
}

image_clear :: proc(self: ^Image_Reader, value: ^Image)
{
    sdl.DestroyTexture(value.data)
}
