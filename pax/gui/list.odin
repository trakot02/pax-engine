package gui

List_Group :: struct
{
    //
    // Defines the direction of the group.
    //
    direction: Direction,

    //
    // Defines extra space in pixels between each child.
    //
    between: f32,

    //
    // Defines if each child should stretch in the opposite direction of the
    // group. In other words if it grows vertically each element stretches
    // horizontally, and the other way around.
    //
    // Note: This ignores every item's size constraints in the stretching
    //       direction.
    //
    stretch: b32,
}

//
//
//
compute_list_size :: proc(state: ^State, handle: Handle, list: ^List_Group)
{
    item  := find_first(state, handle)
    count := 0
    size  := [2]f32 {}

    for ; item.slot != 0; item = find_next(state, item) {
        compute_size(state, item)

        switch list.direction {
            case .ROW: {
                size.x += item.bounds.z
                size.y  = max(size.y, item.bounds.w)
            }

            case .COL: {
                size.y += item.bounds.w
                size.x  = max(size.x, item.bounds.z)
            }
        }

        count += 1
    }

    if count != 0 {
        switch list.direction {
            case .ROW: size.x += list.between * f32(count - 1)
            case .COL: size.y += list.between * f32(count - 1)
        }
    }

    if list.stretch == true {
        item = find_first(state, handle)

        for ; item.slot != 0; item = find_next(state, item) {
            switch list.direction {
                case .ROW: item.bounds.w = size.y
                case .COL: item.bounds.z = size.x
            }
        }
    }

    handle.bounds.zw = size
}

//
//
//
compute_list_part :: proc(state: ^State, handle: Handle, list: ^List_Group, size: [2]f32)
{
    item  := find_first(state, handle)
    count := 0
    size  := [2]f32 {}

    for ; item.slot != 0; item = find_next(state, item) {
        compute_size(state, item)

        switch list.direction {
            case .ROW: {
                size.x += item.bounds.z
                size.y  = max(size.y, item.bounds.w)
            }

            case .COL: {
                size.y += item.bounds.w
                size.x  = max(size.x, item.bounds.z)
            }
        }

        count += 1
    }

    if count != 0 {
        switch list.direction {
            case .ROW: size.x += list.between * f32(count - 1)
            case .COL: size.y += list.between * f32(count - 1)
        }
    }

    if list.stretch == true {
        item = find_first(state, handle)

        for ; item.slot != 0; item = find_next(state, item) {
            switch list.direction {
                case .ROW: item.bounds.w = size.y
                case .COL: item.bounds.z = size.x
            }
        }
    }

    handle.bounds.zw = size
}

//
//
//
compute_list_pos :: proc(state: ^State, handle: Handle, list: ^List_Group)
{
    compute_own_pos(state, handle)

    item := find_first(state, handle)
    pos  := handle.bounds.xy

    for ; item.slot != 0; item = find_next(state, item) {
        item.bounds.xy = pos

        switch list.direction {
            case .ROW: {
                item.bounds.y -= item.origin.y * item.bounds.w
                item.bounds.y += item.factor.y * handle.bounds.w

                pos.x  = item.bounds.x
                pos.x += item.bounds.z + list.between
            }

            case .COL: {
                item.bounds.x -= item.origin.x * item.bounds.z
                item.bounds.x += item.factor.x * handle.bounds.z

                pos.y  = item.bounds.y
                pos.y += item.bounds.w + list.between
            }
        }

        compute_rec_pos(state, item)
    }
}
