package gui

import "core:log"

State :: struct
{
    //
    // Tracks which element is focused by the keyboard. If zero no element
    // has keyboard focus.
    //
    keyboard_focus: int,

    //
    // Tracks which element is focused by the mouse. If zero no element has
    // mouse focus.
    //
    mouse_focus: ^Element,

    //
    // Contains all the elements.
    //
    values: [dynamic]Element,
}

Node :: struct
{
    //
    // Pointer to the node's parent. If zero the node is a root.
    //
    parent: int,

    //
    // Pointer to the node's first child. If zero, so is "last", and the node
    // is a leaf. If the node has only one child, "first" is equal to "last".
    //
    first: int,

    //
    // Pointer to the node's last child. If zero, so is "first", and the node
    // is a leaf. If the node has only one child, "last" is equal to "first".
    //
    last: int,

    //
    // Pointer to the node's previous brother. If zero the node is the first
    // child of its parent.
    //
    prev: int,

    //
    // Pointer to the node's next brother. If zero the node is the last child
    // of its parent.
    //
    next: int,
}

Shape :: struct
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
}

Color :: struct
{
    //
    //
    //
    border: [4]u8,

    //
    //
    //
    fill: [4]u8,

    //
    //
    //
    text: [4]u8,
}

Element :: struct
{
    using shape: Shape,
    using color: Color,
    using node:  Node,

    //
    // If present, changes how the element behaves.
    //
    layout: Layout,
}

Direction :: enum
{
    ROW, COL
}

Placement :: enum
{
    //
    // Each child is placed tightly at the start of the container.
    //
    ALIGN_BEGIN,

    //
    // Each child is placed tightly at the end of the container.
    //
    ALIGN_END,

    //
    // Each child is placed tightly at the center of the container.
    //
    ALIGN_CENTER,

    //
    // Each child fills its own portion of the container.
    //
    FILL,
}

Layout :: union
{
    //
    //
    //
    List_Layout,

    //
    //
    //
    Flex_Layout,
}

List_Layout :: struct
{
    //
    // Direction of the list container.
    //
    direction: Direction,

    //
    // Space in pixels between each child.
    //
    between: f32,

    //
    // If true, each child stretches in the opposite direction
    // of the container. In other words if the list grows vertically
    // each element stretches horizontally, and the other way around.
    //
    stretch: bool,
}

Flex_Layout :: struct
{
    //
    // Direction of the flex container.
    //
    direction: Direction,

    //
    // Defines how each child should be placed.
    //
    placement: Placement,

    //
    // Space in pixels between each child.
    //
    between: f32,

    //
    // If true, each child stretches in the opposite direction
    // of the container. In other words if the list grows vertically
    // each element stretches horizontally, and the other way around.
    //
    stretch: bool,
}

//
//
//
init :: proc(self: ^State, allocator := context.allocator)
{
    self.values = make([dynamic]Element, allocator)
}

//
//
//
destroy :: proc(self: ^State)
{
    delete(self.values)

    self.keyboard_focus = 0
    self.mouse_focus    = nil
    self.values         = {}
}

//
//
//
find :: proc(self: ^State, elem: int) -> ^Element
{
    if elem <= 0 || elem > len(self.values) {
        return nil
    }

    return &self.values[elem - 1]
}

children :: proc(self: ^State, elem: ^Element) -> int
{
    count := 0

    if elem == nil { return count }

    child := find(self, elem.first)

    for ; child != nil; count += 1 {
        child = find(self, child.next)
    }

    return count
}

//
//
//
append_child :: proc(self: ^State, parent: int, element: Element) -> (int, bool)
{
    if parent < 0 || parent > len(self.values) {
        return 0, false
    }

    index    := len(self.values)
    _, error := append(&self.values, element)

    if error != nil {
        log.errorf("Unable to insert element %v",
            element)

        return 0, false
    }

    elem        := &self.values[index]
    elem.parent  = parent

    if 0 < elem.parent && elem.parent <= len(self.values) {
        parent := &self.values[elem.parent - 1]

        if parent.first <= 0 || parent.first > len(self.values) {
            parent.first = index + 1
        }

        if 0 < parent.last && parent.last <= len(self.values) {
            prev := &self.values[parent.last - 1]

            prev.next = index + 1
        }

        elem.prev   = parent.last
        parent.last = index + 1
    }

    return index + 1, true
}

//
//
//
compute_base_size :: proc(state: ^State, self: ^Element)
{
    if self == nil { return }

    parent := find(state, self.parent)

    self.absolute.zw = self.offset.zw

    if parent != nil {
        self.absolute.zw += parent.absolute.zw *
            self.relative.zw
    }
}

//
//
//
compute_base_pos :: proc(state: ^State, self: ^Element)
{
    if self == nil { return }

    parent := find(state, self.parent)

    self.absolute.xy  = self.offset.xy
    self.absolute.xy -= self.origin * self.absolute.zw

    if parent != nil {
        self.absolute.xy += parent.absolute.zw *
            self.relative.xy + parent.absolute.xy
    }
}

//
//
//
compute_child_size :: proc(state: ^State, self: ^Element)
{
    if self == nil { return }

    child := find(state, self.first)

    for ; child != nil; child = find(state, child.next) {
        compute_size(state, child)
    }
}

//
//
//
compute_child_pos :: proc(state: ^State, self: ^Element)
{
    if self == nil { return }

    child := find(state, self.first)

    for ; child != nil; child = find(state, child.next) {
        compute_pos(state, child)
    }
}

//
//
//
compute_list_size :: proc(state: ^State, self: ^Element, layout: ^List_Layout)
{
    if self == nil { return }

    rect  := self.absolute
    child := find(state, self.first)
    count := 0

    for ; child != nil; child = find(state, child.next) {
        compute_size(state, child)

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

    if count > 1 {
        switch layout.direction {
            case .COL: rect.w += layout.between * f32(count - 1)
            case .ROW: rect.z += layout.between * f32(count - 1)
        }
    }

    if layout.stretch == true {
        child = find(state, self.first)

        for ; child != nil; child = find(state, child.next) {
            switch layout.direction {
                case .COL: child.absolute.z = rect.z
                case .ROW: child.absolute.w = rect.w
            }
        }
    }

    self.absolute.zw = rect.zw
}

//
//
//
compute_list_pos :: proc(state: ^State, self: ^Element, layout: ^List_Layout)
{
    if self == nil { return }

    compute_base_pos(state, self)

    rect  := self.absolute
    child := find(state, self.first)

    for ; child != nil; child = find(state, child.next) {
        child.absolute.xy = rect.xy

        switch layout.direction {
            case .COL: {
                child.absolute.x -= child.origin.x   * child.absolute.z
                child.absolute.x += child.relative.x * self.absolute.z

                rect.y  = child.absolute.y
                rect.y += child.absolute.w + layout.between
            }

            case .ROW: {
                child.absolute.y -= child.origin.y   * child.absolute.w
                child.absolute.y += child.relative.y * self.absolute.w

                rect.x  = child.absolute.x
                rect.x += child.absolute.z + layout.between
            }
        }

        compute_child_pos(state, child)
    }
}

compute_flex_size :: proc(state: ^State, self: ^Element, layout: ^Flex_Layout)
{
    if self == nil { return }

    compute_base_size(state, self)

    part  := self.absolute
    count := children(state, self)

    if count > 1 {
        switch layout.direction {
            case .ROW: {
                part.z -= layout.between * f32(count - 1)
                part.z /= f32(count)
            }

            case .COL: {
                part.w -= layout.between * f32(count - 1)
                part.w /= f32(count)
            }
        }
    }

    child := find(state, self.first)

    for ; child != nil; child = find(state, child.next) {
        child.absolute.zw = child.offset.zw + part.zw * child.relative.zw

        if layout.placement == .FILL {
            switch layout.direction {
                case .COL: child.absolute.w = part.w
                case .ROW: child.absolute.z = part.z
            }
        }
    }

    if layout.stretch == true {
        child = find(state, self.first)

        for ; child != nil; child = find(state, child.next) {
            switch layout.direction {
                case .COL: child.absolute.z = part.z
                case .ROW: child.absolute.w = part.w
            }
        }
    }
}

//
//
//
compute_flex_pos :: proc(state: ^State, self: ^Element, layout: ^Flex_Layout)
{
    if self == nil { return }

    compute_base_pos(state, self)

    part  := self.absolute
    child := find(state, self.first)

    for ; child != nil; child = find(state, child.next) {
        child.absolute.xy = part.xy

        switch layout.direction {
            case .COL: {
                child.absolute.x -= child.origin.x   * child.absolute.z
                child.absolute.x += child.relative.x * self.absolute.z

                part.y  = child.absolute.y
                part.y += child.absolute.w + layout.between
            }

            case .ROW: {
                child.absolute.y -= child.origin.y   * child.absolute.w
                child.absolute.y += child.relative.y * self.absolute.w

                part.x  = child.absolute.x
                part.x += child.absolute.z + layout.between
            }
        }
    }

    child = find(state, self.last)

    if child == nil { return }

    offset := self.absolute.xy + self.absolute.zw - child.absolute.xy - child.absolute.zw
    child   = find(state, self.first)

    for ; child != nil; child = find(state, child.next) {
        #partial switch layout.placement {
            case .ALIGN_CENTER: switch layout.direction {
                case .COL: child.absolute.y += offset.y / 2
                case .ROW: child.absolute.x += offset.x / 2
            }

            case .ALIGN_END: switch layout.direction {
                case .COL: child.absolute.y += offset.y
                case .ROW: child.absolute.x += offset.x
            }
        }
    }
}

//
//
//
compute_size :: proc(state: ^State, self: ^Element)
{
    if self == nil { return }

    switch &type in self.layout {
        case List_Layout: compute_list_size(state, self, &type)
        case Flex_Layout: compute_flex_size(state, self, &type)

        case nil: {
            compute_base_size(state, self)
            compute_child_size(state, self)
        }
    }
}

//
//
//
compute_pos :: proc(state: ^State, self: ^Element)
{
    if self == nil { return }

    switch &type in self.layout {
        case List_Layout: compute_list_pos(state, self, &type)
        case Flex_Layout: compute_flex_pos(state, self, &type)

        case nil: {
            compute_base_pos(state, self)
            compute_child_pos(state, self)
        }
    }
}

//
//
//
update_layout :: proc(state: ^State, root: int, size: [2]f32)
{
    self := find(state, root)

    if self != nil {
        parent := find(state, self.parent)

        assert(parent == nil, "Given element is not root")

        self.offset.zw = size

        compute_size(state, self)
        compute_pos(state, self)
    }
}

//
//
//
set_mouse_focus :: proc(state: ^State, self: ^Element, point: [2]f32) -> bool
{
    if self == nil { return false }

    point_in_rect(self.absolute, point) or_return

    child := find(state, self.first)

    for ; child != nil; child = find(state, child.next) {
        if set_mouse_focus(state, child, point) { return true }
    }

    state.mouse_focus = self

    return true
}

//
//
//
update_mouse_focus :: proc(state: ^State, root: int, point: [2]f32)
{
    self := find(state, root)

    if self != nil {
        parent := find(state, self.parent)

        assert(parent == nil, "Given element is not root")

        state.mouse_focus = nil

        set_mouse_focus(state, self, point)
    }
}

//
//
//
update_keyboard_focus :: proc(state: ^State, root: int, step: [2]bool)
{
    self := find(state, root)

    if self != nil {
        parent := find(state, self.parent)

        assert(parent == nil, "Given element is not root")

        state.keyboard_focus += int(step.y)
        state.keyboard_focus  = min(state.keyboard_focus, len(state.values))

        state.keyboard_focus -= int(step.x)
        state.keyboard_focus  = max(state.keyboard_focus, 1)
    }
}

//
//
//
point_in_rect :: proc(rect: [4]f32, point: [2]f32) -> bool
{
    return rect.x <= point.x && point.x <= rect.x + rect.z &&
           rect.y <= point.y && point.y <= rect.y + rect.w
}
