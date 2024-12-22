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

Image_Registry :: struct
{
    //
    //
    //
    renderer: ^Renderer,

    //
    //
    //
    values: [dynamic]Image,
}

//
//
//
@(private)
image_destroy :: proc(self: ^Image_Registry, image: ^Image)
{
    sdl.DestroyTexture(auto_cast image.data)
}

//
//
//
@(private)
image_read :: proc(self: ^Image_Registry, name: string) -> (Image, bool)
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
// todo (trakot02): In the future...
//
@(private)
image_write :: proc(self: ^Image_Registry, name: string, value: ^Image) -> bool
{
    return false
}

//
//
//
image_registry_init :: proc(self: ^Image_Registry, renderer: ^Renderer, allocator := context.allocator)
{
    self.renderer = renderer
    self.values   = make([dynamic]Image, allocator)
}

//
//
//
image_registry_destroy :: proc(self: ^Image_Registry)
{
    delete(self.values)

    self.values   = {}
    self.renderer = {}
}

//
//
//
image_registry_insert :: proc(self: ^Image_Registry, image: Image) -> (int, bool)
{
    index, error := append(&self.values, image)

    if error != nil {
        log.errorf("Image_Registry: Unable to insert %v",
            image)

        return 0, false
    }

    return index + 1, true
}

//
//
//
image_registry_remove :: proc(self: ^Image_Registry, image: int)
{
    log.errorf("Image_Registry: Not implemented yet")
}

//
//
//
image_registry_clear :: proc(self: ^Image_Registry)
{
    for &image in self.values {
        image_destroy(self, &image)
    }

    clear(&self.values)
}

//
//
//
image_registry_find :: proc(self: ^Image_Registry, image: int) -> (^Image, bool)
{
    image := image - 1

    if 0 <= image && image < len(self.values) {
        return &self.values[image], true
    }

    return nil, false
}

//
//
//
image_registry_read :: proc(self: ^Image_Registry, name: string) -> bool
{
    value, state := image_read(self, name)

    switch state {
        case false:
            log.errorf("Image_Registry: Unable to read %q",
                name)

        case true:
            image_registry_insert(self, value) or_return
    }

    return state
}
