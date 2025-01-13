package gui

import "core:log"
import "core:strings"
import "core:mem"

import rl "vendor:raylib"

Text_Group :: struct
{
    slot:  int,
    size:  f32,
    space: f32,
    value: string,
    rect:  [4]f32,
}

//
//
//
compute_text_size :: proc(state: ^State, handle: Handle, text: ^Text_Group)
{
    parent := find_parent(state, handle)
    font   := find_font(state, text.slot)

    handle.bounds.zw = handle.offset.zw

    if font.slot != 0 {
        clone, error := strings.clone_to_cstring(text.value,
            context.temp_allocator)

        if error == nil {
            text.rect.zw = rl.MeasureTextEx(font.value^, clone, text.size, text.space)

            handle.bounds.z += text.rect.z
            handle.bounds.w += text.rect.w

            mem.free_all(context.temp_allocator)
        } else {
            log.errorf("Text_Group: Unable to clone to c-string")
        }
    }

    if parent.slot != 0 {
        handle.bounds.zw += handle.factor.zw *
            parent.bounds.zw
    }

    text.rect.xy = handle.bounds.zw / 2 - text.rect.zw / 2

    compute_rec_size(state, handle)
}

//
//
//
compute_text_part :: proc(state: ^State, handle: Handle, text: ^Text_Group, size: [2]f32)
{
    font := find_font(state, text.slot)

    handle.bounds.zw = handle.offset.zw

    if font.slot != 0 {
        clone, error := strings.clone_to_cstring(text.value,
            context.temp_allocator)

        if error == nil {
            text.rect.zw = rl.MeasureTextEx(font.value^, clone, text.size, text.space)

            handle.bounds.z += text.rect.z
            handle.bounds.w += text.rect.w

            mem.free_all(context.temp_allocator)
        } else {
            log.errorf("Text_Group: Unable to clone to c-string")
        }
    }

    handle.bounds.zw += handle.factor.zw * size

    text.rect.xy = handle.bounds.zw / 2 - text.rect.zw / 2

    compute_rec_size(state, handle)
}

//
//
//
compute_text_pos :: proc(state: ^State, handle: Handle, text: ^Text_Group)
{
    compute_own_pos(state, handle)
    compute_rec_pos(state, handle)
}
