package pax

import "core:strings"
import "core:mem"
import "core:log"

import rl "vendor:raylib"

//
//
//
Texture :: rl.Texture2D

Texture_Registry :: struct
{
    //
    //
    //
    resource: Resource,

    //
    //
    //
    registry: Registry(Texture),
}

//
//
//
@(private)
texture_destroy :: proc(self: ^Texture_Registry, texture: ^Texture)
{
    rl.UnloadTexture(texture^)
}

//
//
//
@(private)
texture_read :: proc(self: ^Texture_Registry, name: string) -> (Texture, bool)
{
    alloc := context.temp_allocator
    value := Texture {}

    clone, error := strings.clone_to_cstring(name, alloc)

    if error != nil {
        log.errorf("Texture: Unable to clone %q to c-string",
            name)

        return {}, false
    }

    value = rl.LoadTexture(clone)

    mem.free_all(alloc)

    return value, true
}

//
// todo (trakot02): In the future...
//
@(private)
texture_write :: proc(self: ^Texture_Registry, name: string, value: ^Texture) -> bool
{
    return false
}

//
//
//
texture_registry_init :: proc(self: ^Texture_Registry, allocator := context.allocator)
{
    resource_init(&self.resource, allocator)
    registry_init(&self.registry, allocator)
}

//
//
//
texture_registry_destroy :: proc(self: ^Texture_Registry)
{
    registry_destroy(&self.registry)
    resource_destroy(&self.resource)
}

//
//
//
texture_registry_insert :: proc(self: ^Texture_Registry, texture: Texture) -> (int, bool)
{
    resource, _ := resource_create(&self.resource)
    value, _    := registry_insert(&self.registry, resource, texture)

    if value != nil {
        return resource, true
    }

    resource_delete(&self.resource, resource)

    return 0, false
}

//
//
//
texture_registry_remove :: proc(self: ^Texture_Registry, texture: int) -> bool
{
    value := registry_remove(&self.registry, texture) or_return

    texture_destroy(self, value)

    return resource_delete(&self.resource, texture)
}

//
//
//
texture_registry_clear :: proc(self: ^Texture_Registry)
{
    for &texture in self.registry.values {
        texture_destroy(self, &texture)
    }

    registry_clear(&self.registry)
    resource_clear(&self.resource)
}

//
//
//
texture_registry_find :: proc(self: ^Texture_Registry, texture: int) -> (^Texture, bool)
{
    return registry_find(&self.registry, texture)
}

//
//
//
texture_registry_read :: proc(self: ^Texture_Registry, name: string) -> bool
{
    value, state := texture_read(self, name)

    switch state {
        case false:
            log.errorf("Texture_Registry: Unable to read %q",
                name)

        case true:
            texture_registry_insert(self, value) or_return
    }

    return state
}

texture_size :: proc(self: ^Texture_Registry, sprite: Sprite) -> [2]f32
{
    texture, _ := texture_registry_find(self, sprite.texture)

    if texture == nil { return {} }

    return [2]f32 {
        f32(texture.width),
        f32(texture.height),
    }
}
