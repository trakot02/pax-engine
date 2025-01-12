package gui

Slider_Info :: struct
{
    range: [2]f32,
    step:  f32,

    movement: f32,
    pressed:  b8,
    released: b8,
}

//
//
//
slider :: proc(state: ^State, slot: int, info: Slider_Info, value: ^f32) -> f32
{
    handle := find(state, slot)
    result := f32(0)

    if handle.slot == 0 { return result }

    if is_active(state, handle) {
        result = info.movement * info.step

        if info.released {
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

    if value == nil { return 0 }

    temp := value^ + result

    temp = max(temp, info.range[0])
    temp = min(temp, info.range[1])

    result = temp - value^
    value^ = temp

    return result
}
