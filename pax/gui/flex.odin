package gui

import "core:log"

Flex_Group :: struct
{
    //
    // Defines the direction of the group.
    //
    direction: Direction,

    //
    // Defines the alignment of each item inside the group.
    //
    alignment: Alignment,

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
    stretch: bool,
}

//
//
//
compute_flex_size :: proc(state: ^State, handle: Handle, flex: ^Flex_Group)
{
    compute_own_size(state, handle)

    count := count_children(state, handle)
    size  := handle.bounds.zw

    if count != 0 {
        switch flex.direction {
            case .ROW: {
                size.x -= flex.between * f32(count - 1)
                size.x /= f32(count)
            }

            case .COL: {
                size.y -= flex.between * f32(count - 1)
                size.y /= f32(count)
            }
        }
    }

    item := find_first(state, handle)

    for ; item.slot != 0; item = find_next(state, item) {
        compute_part(state, item, size)

        if flex.alignment == .FILL {
            switch flex.direction {
                case .ROW: item.bounds.z = size.x
                case .COL: item.bounds.w = size.y
            }
        }
    }

    if flex.stretch == true {
        item = find_first(state, handle)

        for ; item.slot != 0; item = find_next(state, item) {
            switch flex.direction {
                case .ROW: item.bounds.w = size.y
                case .COL: item.bounds.z = size.x
            }
        }
    }
}

//
//
//
compute_flex_part :: proc(state: ^State, handle: Handle, flex: ^Flex_Group, size: [2]f32)
{
    compute_own_part(state, handle, size)

    count := count_children(state, handle)
    size  := handle.bounds.zw

    if count != 0 {
        switch flex.direction {
            case .ROW: {
                size.x -= flex.between * f32(count - 1)
                size.x /= f32(count)
            }

            case .COL: {
                size.y -= flex.between * f32(count - 1)
                size.y /= f32(count)
            }
        }
    }

    item := find_first(state, handle)

    for ; item.slot != 0; item = find_next(state, item) {
        compute_part(state, item, size)

        if flex.alignment == .FILL {
            switch flex.direction {
                case .ROW: item.bounds.z = size.x
                case .COL: item.bounds.w = size.y
            }
        }
    }

    if flex.stretch == true {
        item = find_first(state, handle)

        for ; item.slot != 0; item = find_next(state, item) {
            switch flex.direction {
                case .ROW: item.bounds.w = size.y
                case .COL: item.bounds.z = size.x
            }
        }
    }
}

//
//
//
compute_flex_pos :: proc(state: ^State, handle: Handle, flex: ^Flex_Group)
{
    compute_own_pos(state, handle)

    item  := find_first(state, handle)
    count := 0
    pos   := handle.bounds.xy

    for ; item.slot != 0; item = find_next(state, item) {
        item.bounds.xy = pos

        switch flex.direction {
            case .ROW: {
                item.bounds.y -= item.origin.y * item.bounds.w
                item.bounds.y += item.factor.y * handle.bounds.w

                pos.x  = item.bounds.x
                pos.x += item.bounds.z + flex.between
            }

            case .COL: {
                item.bounds.x -= item.origin.x * item.bounds.z
                item.bounds.x += item.factor.x * handle.bounds.z

                pos.y  = item.bounds.y
                pos.y += item.bounds.w + flex.between
            }
        }

        count += 1
    }

    align := [2]f32 {}

    if item = find_last(state, handle); item.slot != 0 {
        align = handle.bounds.xy + handle.bounds.zw -
            item.bounds.xy - item.bounds.zw

        #partial switch flex.alignment {
            case .ALIGN_CENTER: align /= 2
            case .SPACE_APART:  align /= f32(count - 1)
            case .SPACE_EVENLY: align /= f32(count + 1)
            case .SPACE_AROUND: align /= f32(count * 2)
        }
    }

    item = find_first(state, handle)

    if item.slot != 0 { pos = item.bounds.xy }

    for ; item.slot != 0; item = find_next(state, item) {
        #partial switch flex.alignment {
            case .ALIGN_CENTER: switch flex.direction {
                case .ROW: item.bounds.x += align.x
                case .COL: item.bounds.y += align.y
            }

            case .ALIGN_END: switch flex.direction {
                case .ROW: item.bounds.x += align.x
                case .COL: item.bounds.y += align.y
            }

            case .SPACE_APART: switch flex.direction {
                case .ROW: {
                    item.bounds.x = pos.x

                    pos.x += item.bounds.z + align.x
                    pos.x += flex.between
                }

                case .COL: {
                    item.bounds.y = pos.y

                    pos.y += item.bounds.w + align.y
                    pos.y += flex.between
                }
            }

            case .SPACE_EVENLY: switch flex.direction {
                case .ROW: {
                    item.bounds.x = pos.x + align.x

                    pos.x += item.bounds.z + align.x
                    pos.x += flex.between
                }

                case .COL: {
                    item.bounds.y = pos.y + align.y

                    pos.y += item.bounds.w + align.y
                    pos.y += flex.between
                }
            }

            case .SPACE_AROUND: switch flex.direction {
                case .ROW: {
                    item.bounds.x = pos.x + align.x

                    pos.x += item.bounds.z + align.x * 2
                    pos.x += flex.between
                }

                case .COL: {
                    item.bounds.y = pos.y + align.y

                    pos.y += item.bounds.w + align.y * 2
                    pos.y += flex.between
                }
            }
        }

        compute_rec_pos(state, item)
    }
}
