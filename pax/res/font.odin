package res

import "core:log"
import "core:strings"
import "core:mem"

import rl "vendor:raylib"

Font :: rl.Font

//
//
//
font_read :: proc(name: string, size: int) -> Font
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Font: Unable to clone to c-string")

        return {}
    }

    value := rl.LoadFontEx(clone, i32(size), nil, 0)

    mem.free_all(context.temp_allocator)

    return value
}

//
//
//
font_free :: proc(value: Font)
{
    rl.UnloadFont(value)
}

//
//
//
font_read_and_insert :: proc(holder: ^Holder(Font), name: string, size: int) -> (int, bool)
{
    return holder_insert(holder, font_read(name, size))
}

//
//
//
font_remove_and_free :: proc(holder: ^Holder(Font), slot: int)
{
    value, state := holder_remove(holder, slot)

    if state == true {
        font_free(value)
    }
}
