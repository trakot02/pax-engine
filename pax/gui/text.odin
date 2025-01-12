package gui

import rl "vendor:raylib"

Text_Group :: struct
{
    slot: int,
    text: string,
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
        size := rl.MeasureTextEx(font.value^, "Test", 0, 1)

        handle.bounds.w += size.y
        handle.bounds.z += size.x
    }

    if parent.slot != 0 {
        handle.bounds.zw += handle.factor.zw *
            parent.bounds.zw
    }

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
        size := rl.MeasureTextEx(font.value^, "Test", 0, 1)

        handle.bounds.w += size.y
        handle.bounds.z += size.x
    }

    handle.bounds.zw += handle.factor.zw * size

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
