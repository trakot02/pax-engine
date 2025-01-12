package res

import "core:log"
import "core:strings"
import "core:mem"

import rl "vendor:raylib"

Texture :: rl.Texture2D

//
//
//
texture_read :: proc(name: string) -> Texture
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator
    )

    if error != nil {
        log.errorf("Texture: Unable to clone to c-string")

        return {}
    }

    value := rl.LoadTexture(clone)

    mem.free_all(context.temp_allocator)

    return value
}

//
//
//
texture_free :: proc(value: Texture)
{
    rl.UnloadTexture(value)
}

//
//
//
texture_read_and_insert :: proc(holder: ^Holder(Texture), name: string) -> (int, bool)
{
    return holder_insert(holder, texture_read(name))
}

//
//
//
texture_remove_and_free :: proc(holder: ^Holder(Texture), slot: int)
{
    value, state := holder_remove(holder, slot)

    if state == true {
        texture_free(value)
    }
}
