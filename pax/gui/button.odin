package gui

Button_Info :: struct
{
    pressed:  b8,
    released: b8,
}

//
//
//
button :: proc(state: ^State, slot: int, info: Button_Info) -> bool
{
    handle := find(state, slot)
    result := false

    if handle.slot == 0 { return false }

    if is_active(state, handle) {
        if info.released {
            if point_in_rect(handle.bounds, state.cursor) {
                result = true
            }

            set_active(state, {})
        }
    } else if is_target(state, handle) {
        if info.pressed {
            set_active(state, handle)
        }
    }

    if point_in_rect(handle.bounds, state.cursor) {
        set_target(state, handle)
    }

    return result
}
