package gui

List_Direction :: enum
{
    //
    //
    //
    ROW,

    //
    //
    //
    COL,
}

List_Alignment :: enum
{
    //
    //
    //
    DEFAULT,

    //
    //
    //
    STRETCH,
}

List_Layout :: struct
{
    //
    //
    //
    direction: List_Direction,

    //
    //
    //
    alignment: List_Alignment,

    //
    //
    //
    spacing: f32,
}

//
//
//
compute_list_size :: proc(values: [dynamic]Element, self: int, layout: List_Layout)
{
    if self <= 0 || self > len(values) { return }

    elem  := values[self - 1]
    rect  := elem.offset
    count := 0

    for index := elem.first; 0 < index && index <= len(values); {
        compute_size(values, index)

        child := values[index - 1]
        index := child.next

        switch layout.direction {
            case .COL: {
                rect.w += child.absolute.w
                rect.z  = max(rect.z, child.absolute.z)
            }

            case .ROW: {
                rect.z += child.absolute.z
                rect.w  = max(rect.w, child.absolute.w)
            }
        }

        count += 1
    }

    if layout.alignment == .STRETCH {
        for index := elem.first; 0 < index && index <= len(values); {
            child := values[index - 1]
            index := child.next

            switch layout.direction {
                case .COL: child.absolute.z = rect.z
                case .ROW: child.absolute.w = rect.w
            }
        }
    }

    if count > 1 {
        switch layout.direction {
            case .COL: rect.w += layout.spacing * f32(count - 1)
            case .ROW: rect.z += layout.spacing * f32(count - 1)
        }
    }

    elem.absolute = rect
}

//
//
//
compute_list_pos :: proc(values: [dynamic]Element, self: int, layout: List_Layout)
{
    compute_base_pos(values, self)

    elem := values[self - 1]
    rect := elem.absolute

    for index := elem.first; 0 < index && index <= len(values); {
        child := values[index - 1]
        index  = child.next

        switch layout.direction {
            case .COL: {
                child.absolute.xy  = child.offset.xy  + rect.xy
                child.absolute.x  -= child.origin.x   * child.absolute.z
                child.absolute.x  += child.relative.x * elem.absolute.z

                rect.y  = child.absolute.y
                rect.y += child.absolute.w + layout.spacing
            }

            case .ROW: {
                child.absolute.xy  = child.offset.xy  + rect.xy
                child.absolute.y  -= child.origin.y   * child.absolute.w
                child.absolute.y  += child.relative.y * elem.absolute.w

                rect.x  = child.absolute.x
                rect.x += child.absolute.z + layout.spacing
            }
        }

        for index := child.first; 0 < index && index <= len(values); {
            compute_pos(values, index)

            child = values[index - 1]
            index = child.next
        }
    }
}

Layout :: union
{
    //
    //
    //
    List_Layout,
}

//
//
//
compute_base_size :: proc(values: [dynamic]Element, self: int)
{
    if self < 0 || self >= len(values) { return }

    elem := values[self - 1]

    elem.absolute.zw = elem.offset.zw

    if 0 < elem.parent && elem.parent < len(values) {
        parent := values[elem.parent - 1]

        elem.absolute.zw += parent.absolute.zw *
            elem.relative.zw
    }
}

//
//
//
compute_base_pos :: proc(values: [dynamic]Element, self: int)
{
    if self < 0 || self >= len(values) { return }

    elem := values[self - 1]

    elem.absolute.xy  = elem.offset.xy
    elem.absolute.xy -= elem.origin * elem.absolute.zw

    if 0 < elem.parent && elem.parent < len(values) {
        parent := values[elem.parent - 1]

        elem.absolute.xy += parent.absolute.zw *
            elem.relative.xy + parent.absolute.xy
    }
}

Element_Flag :: enum
{
    //
    //
    //
    KEYBOARD_FOCUS,

    //
    //
    //
    MOUSE_FOCUS,
}

Element_State :: distinct bit_set[Element_Flag]

Element :: struct
{
    //
    //
    //
    absolute: [4]f32,

    //
    //
    //
    relative: [4]f32,

    //
    //
    //
    origin: [2]f32,

    //
    //
    //
    offset: [4]f32,

    //
    //
    //
    color: [4]u8,

    //
    //
    //
    state: Element_State,

    //
    //
    //
    layout: Layout,

    //
    //
    //
    parent: int,

    //
    //
    //
    first: int,

    //
    //
    //
    last: int,

    //
    //
    //
    prev: int,

    //
    //
    //
    next: int,
}

//
//
//
compute_size :: proc(values: [dynamic]Element, self: int)
{
    if self <= 0 || self > len(values) { return }

    elem := values[self - 1]

    switch type in elem.layout {
        case List_Layout: compute_list_size(values, self, type)

        case nil: {
            compute_base_size(values, self)

            for index := elem.first; 0 < index && index <= len(values); {
                compute_size(values, index)

                child := values[index - 1]
                index  = child.next
            }
        }
    }
}

//
//
//
compute_pos :: proc(values: [dynamic]Element, self: int)
{
    if self <= 0 || self > len(values) { return }

    elem := values[self - 1]

    switch type in elem.layout {
        case List_Layout: compute_list_pos(values, self, type)

        case nil: {
            compute_base_pos(values, self)

            for index := elem.first; 0 < index && index <= len(values); {
                compute_pos(values, index)

                child := values[index - 1]
                index  = child.next
            }
        }
    }
}

//
//
//
set_mouse_focus :: proc(values: [dynamic]Element, self: int, point: [2]f32) -> bool
{
    if self <= 0 || self > len(values) { return false }

    elem := values[self - 1]

    point_in_rect(elem.absolute, point) or_return

    for index := elem.first; 0 < index && index <= len(values); {
        if set_mouse_focus(values, index, point) {
            return true
        }

        child := values[index - 1]
        index  = child.next
    }

    elem.state += {.MOUSE_FOCUS}

    return true
}

//
//
//
update_layout :: proc(values: [dynamic]Element, root: int, size: [2]f32)
{
    if root <= 0 || root > len(values) { return }

    elem := values[root - 1]

    assert(elem.parent <= 0 || elem.parent > len(values),
        "Given element is not root")

    elem.offset.zw = size

    compute_size(values, root)
    compute_pos(values, root)
}

//
//
//
update_mouse :: proc(values: [dynamic]Element, root: int, point: [2]f32)
{
    if root <= 0 || root > len(values) { return }

    elem := values[root - 1]

    assert(elem.parent <= 0 || elem.parent > len(values),
        "Given element is not root")

    for &elem in values {
        elem.state -= {.MOUSE_FOCUS}
    }

    set_mouse_focus(values, root, point)
}

//
//
//
point_in_rect :: proc(rect: [4]f32, point: [2]f32) -> bool
{
    return rect.x <= point.x && point.x <= rect.x + rect.z &&
           rect.y <= point.y && point.y <= rect.y + rect.w
}
