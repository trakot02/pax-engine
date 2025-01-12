package pax

import "core:strings"
import "core:mem"
import "core:log"

import rl "vendor:raylib"

//
//
//
Font :: rl.Font

Text :: struct
{
    font:    int,
    content: string,
    spacing: f32,
    size:    f32,
    color:   [4]u8,
}

Font_Registry :: struct
{
    //
    //
    //
    resource: Resource,

    //
    //
    //
    registry: Registry(Font),
}

//
//
//
@(private)
font_destroy :: proc(self: ^Font_Registry, font: ^Font)
{
    rl.UnloadFont(font^)
}

//
//
//
@(private)
font_read :: proc(self: ^Font_Registry, name: string) -> (Font, bool)
{
    alloc := context.temp_allocator
    value := Font {}

    clone, error := strings.clone_to_cstring(name, alloc)

    if error != nil {
        log.errorf("Font: Unable to clone %q to c-string",
            name)

        return {}, false
    }

    value = rl.LoadFont(clone)

    mem.free_all(alloc)

    return value, true
}

//
// todo (trakot02): In the future...
//
@(private)
font_write :: proc(self: ^Font_Registry, name: string, value: ^Font) -> bool
{
    return false
}

//
//
//
font_registry_init :: proc(self: ^Font_Registry, allocator := context.allocator)
{
    resource_init(&self.resource, allocator)
    registry_init(&self.registry, allocator)
}

//
//
//
font_registry_destroy :: proc(self: ^Font_Registry)
{
    registry_destroy(&self.registry)
    resource_destroy(&self.resource)
}

//
//
//
font_registry_insert :: proc(self: ^Font_Registry, font: Font) -> (int, bool)
{
    resource, _ := resource_create(&self.resource)
    value, _    := registry_insert(&self.registry, resource, font)

    if value != nil {
        return resource, true
    }

    resource_delete(&self.resource, resource)

    return 0, false
}

//
//
//
font_registry_remove :: proc(self: ^Font_Registry, font: int) -> bool
{
    value := registry_remove(&self.registry, font) or_return

    font_destroy(self, value)

    return resource_delete(&self.resource, font)
}

//
//
//
font_registry_clear :: proc(self: ^Font_Registry)
{
    for &font in self.registry.values {
        font_destroy(self, &font)
    }

    registry_clear(&self.registry)
    resource_clear(&self.resource)
}

//
//
//
font_registry_find :: proc(self: ^Font_Registry, font: int) -> (^Font, bool)
{
    return registry_find(&self.registry, font)
}

//
//
//
font_registry_read :: proc(self: ^Font_Registry, name: string) -> bool
{
    value, state := font_read(self, name)

    switch state {
        case false:
            log.errorf("Font_Registry: Unable to read %q",
                name)

        case true:
            font_registry_insert(self, value) or_return
    }

    return state
}

font_measure :: proc(self: ^Font_Registry, text: Text) -> [2]f32
{
    font, _ := font_registry_find(self, text.font)
    alloc   := context.temp_allocator

    if font == nil { return {} }

    clone, error := strings.clone_to_cstring(text.content, alloc)

    if error != nil {
        log.errorf("Font: Unable to clone %q to c-string",
            text.content)

        return {}
    }

    result := rl.MeasureTextEx(font^, clone, text.size, text.spacing)

    mem.free_all(alloc)

    return result
}
