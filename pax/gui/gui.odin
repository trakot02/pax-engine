package gui

import "core:log"

import ".."

import rl "vendor:raylib"

//
//
// Definitions.
//
//

Node :: struct
{
    //
    // Pointer to the node's parent. If zero, the node is a root.
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
    // Pointer to the node's previous brother. If zero, the node is the first
    // child of its parent.
    //
    prev: int,

    //
    // Pointer to the node's next brother. If zero, the node is the last child
    // of its parent.
    //
    next: int,
}

Shape :: struct
{
    //
    // Fixed offsets used to compute an element's absolute bounds.
    //
    offset: [4]f32,

    //
    // Point around which the element's bounds are computed. Especially useful
    // to center or align an element to a specific side of its parent. If the
    // element has no parent, "origin" has no meaning.
    //
    // Note: Each layout can apply a different meaning to "origin", so refer to
    //       that layout's specific notes.
    //
    origin: [2]f32,

    //
    // Bounds relative to the element's parent. If the element has no parent,
    // "relative" has no meaning.
    //
    // Note: Each layout can apply a different meaning to "relative", so refer
    //       to that layout's specific notes.
    //
    relative: [4]f32,

    //
    // Absolute bounds computed by the system used to draw and interact with
    // the element.
    //
    // Note: These bounds shouldn't be manually altered.
    //
    absolute: [4]f32,
}

Color :: struct
{
    //
    // Color applied to the element's border.
    //
    border: [4]u8,

    //
    // Color applied to the element's inside.
    //
    fill: [4]u8,

    //
    // Color applied to the element's text.
    //
    text: [4]u8,
}

Layout :: union
{
    List_Layout, Flex_Layout,
}

Element :: struct
{
    node:   Node,
    shape:  Shape,
    color:  Color,
    layout: Layout,
}

State :: struct
{
    //
    // Tracks which element is the root.
    //
    root: int,

    //
    // Tracks which element is focused. If zero, no element is focused.
    //
    // For example focus can be gained by an element when it gets clicked
    // with a mouse button or after tab is released.
    //
    focus: int,

    //
    // Tracks which element is hovered. If zero, no element is hovered.
    //
    // For example hover can be gained by an element when the mouse enters
    // its bounds or when the same happens using a controller's stick.
    //
    hover: int,

    //
    //
    //
    elems: [dynamic]Element,
}

Direction :: enum
{
    ROW, COL
}

Placement :: enum
{
    //
    // Each child is placed tightly at the beginning of the container.
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
    // Each child is placed at the maximum possible distance from
    // its brothers.
    //
    SPACE_APART,

    //
    // Each child is placed at the maximum possible distance from
    // its brothers and the cointainer's sides.
    //
    SPACE_EVENLY,

    //
    // Each child is placed with the maximum possible space around
    // both its sides.
    //
    SPACE_AROUND,

    //
    // Each child fills its own portion of the container.
    //
    FILL,
}

List_Layout :: struct
{
    //
    // Direction of the container.
    //
    direction: Direction,

    //
    // Space in pixels between each child.
    //
    between: f32,
}

Flex_Layout :: struct
{
    //
    // Direction of the container.
    //
    direction: Direction,

    //
    // Defines how each child should be placed in the direction of the container.
    //
    placement: Placement,

    //
    // Space in pixels between each child.
    //
    between: f32,

    //
    // If true, each child stretches in the opposite direction of the container.
    // In other words if the list grows vertically each element stretches
    // horizontally, and the other way around.
    //
    // Note: This overrides every shape's size constraints in the stretching
    //       direction.
    //
    stretch: bool,
}

//
//
// Implementation.
//
//

//
//
//
init :: proc(state: ^State, allocator := context.allocator)
{
    state.root  = 1
    state.elems = make([dynamic]Element, allocator)
}

//
//
//
destroy :: proc(state: ^State)
{
    delete(state.elems)

    state.root  = 0
    state.focus = 0
    state.hover = 0
    state.elems = {}
}

//
//
//
append_child :: proc(state: ^State, parent: int, shape: Shape, color: Color, layout: Layout) -> int
{
    count := len(state.elems)

    if parent < 0 || parent > count { return 0 }

    _, error := assign_at(&state.elems, count, Element {
        shape = shape, color = color, layout = layout, node = {
            parent = parent
        },
    })

    if error != nil {
        log.errorf("Unable to insert element %v, %v, %v",
            shape, color, layout)

        return 0
    }

    count += 1
    self  := find(state, count)

    if self == nil { return 0 }

    if self.node.parent != 0 {
        parent := find(state, self.node.parent)
        prev   := find(state, parent.node.last)
        first  := find(state, parent.node.first)

        if first == nil { parent.node.first = count }
        if prev  != nil { prev.node.next    = count }

        self.node.prev   = parent.node.last
        parent.node.last = count
    }

    return count
}

//
//
//
find :: proc(state: ^State, elem: int) -> ^Element
{
    if 0 < elem && elem <= len(state.elems) {
        return &state.elems[elem - 1]
    }

    return nil
}

//
//
//
children :: proc(state: ^State, self: ^Element) -> int
{
    if self == nil { return 0 }

    child := find(state, self.node.first)
    count := 0

    for ; child != nil; count += 1 {
        child = find(state, child.node.next)
    }

    return count + 1
}

//
//
//
compute_base_size :: proc(state: ^State, self: ^Element)
{
    if self == nil { return }

    parent := find(state, self.node.parent)

    self.shape.absolute.zw = self.shape.offset.zw

    if parent != nil {
        self.shape.absolute.zw += parent.shape.absolute.zw *
            self.shape.relative.zw
    }
}

//
//
//
compute_base_pos :: proc(state: ^State, self: ^Element)
{
    if self == nil { return }

    parent := find(state, self.node.parent)

    self.shape.absolute.xy  = self.shape.offset.xy
    self.shape.absolute.xy -= self.shape.origin * self.shape.absolute.zw

    if parent != nil {
        self.shape.absolute.xy += parent.shape.absolute.zw *
            self.shape.relative.xy + parent.shape.absolute.xy
    }
}

//
//
//
compute_tree_size :: proc(state: ^State, self: ^Element)
{
    if self == nil { return }

    child := find(state, self.node.first)

    for ; child != nil; child = find(state, child.node.next) {
        compute_size(state, child)
    }
}

//
//
//
compute_tree_pos :: proc(state: ^State, self: ^Element)
{
    if self == nil { return }

    child := find(state, self.node.first)

    for ; child != nil; child = find(state, child.node.next) {
        compute_pos(state, child)
    }
}

//
//
//
compute_list_size :: proc(state: ^State, self: ^Element, layout: ^List_Layout)
{
    if self == nil { return }

    rect  := self.shape.absolute
    child := find(state, self.node.first)
    count := 0

    for ; child != nil; child = find(state, child.node.next) {
        compute_size(state, child)

        switch layout.direction {
            case .COL: {
                rect.w += child.shape.absolute.w
                rect.z  = max(rect.z, child.shape.absolute.z)
            }

            case .ROW: {
                rect.z += child.shape.absolute.z
                rect.w  = max(rect.w, child.shape.absolute.w)
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

    self.shape.absolute.zw = rect.zw
}

//
//
//
compute_list_pos :: proc(state: ^State, self: ^Element, layout: ^List_Layout)
{
    if self == nil { return }

    compute_base_pos(state, self)

    rect  := self.shape.absolute
    child := find(state, self.node.first)

    for ; child != nil; child = find(state, child.node.next) {
        child.shape.absolute.xy = rect.xy

        switch layout.direction {
            case .COL: {
                child.shape.absolute.x -= child.shape.origin.x   * child.shape.absolute.z
                child.shape.absolute.x += child.shape.relative.x * self.shape.absolute.z

                rect.y  = child.shape.absolute.y
                rect.y += child.shape.absolute.w + layout.between
            }

            case .ROW: {
                child.shape.absolute.y -= child.shape.origin.y   * child.shape.absolute.w
                child.shape.absolute.y += child.shape.relative.y * self.shape.absolute.w

                rect.x  = child.shape.absolute.x
                rect.x += child.shape.absolute.z + layout.between
            }
        }

        compute_tree_pos(state, child)
    }
}

compute_flex_size :: proc(state: ^State, self: ^Element, layout: ^Flex_Layout)
{
    if self == nil { return }

    compute_base_size(state, self)

    part  := self.shape.absolute
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

    child := find(state, self.node.first)

    for ; child != nil; child = find(state, child.node.next) {
        child.shape.absolute.zw = child.shape.offset.zw + part.zw *
            child.shape.relative.zw

        if layout.placement == .FILL {
            switch layout.direction {
                case .COL: child.shape.absolute.w = part.w
                case .ROW: child.shape.absolute.z = part.z
            }
        }
    }

    if layout.stretch == true {
        child = find(state, self.node.first)

        for ; child != nil; child = find(state, child.node.next) {
            switch layout.direction {
                case .COL: child.shape.absolute.z = part.z
                case .ROW: child.shape.absolute.w = part.w
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

    part  := self.shape.absolute
    child := find(state, self.node.first)
    count := 0

    for ; child != nil; child = find(state, child.node.next) {
        child.shape.absolute.xy = part.xy

        switch layout.direction {
            case .COL: {
                child.shape.absolute.x -= child.shape.origin.x   * child.shape.absolute.z
                child.shape.absolute.x += child.shape.relative.x * self.shape.absolute.z

                part.y  = child.shape.absolute.y
                part.y += child.shape.absolute.w + layout.between
            }

            case .ROW: {
                child.shape.absolute.y -= child.shape.origin.y   * child.shape.absolute.w
                child.shape.absolute.y += child.shape.relative.y * self.shape.absolute.w

                part.x  = child.shape.absolute.x
                part.x += child.shape.absolute.z + layout.between
            }
        }

        count += 1
    }

    child = find(state, self.node.last)

    if child == nil { return }

    align := self.shape.absolute.xy + self.shape.absolute.zw -
        child.shape.absolute.xy - child.shape.absolute.zw

    child = find(state, self.node.first)

    #partial switch layout.placement {
        case .ALIGN_CENTER: {
            for ; child != nil; child = find(state, child.node.next) {
                switch layout.direction {
                    case .COL: child.shape.absolute.y += align.y / 2
                    case .ROW: child.shape.absolute.x += align.x / 2
                }
            }
        }

        case .ALIGN_END: {
            for ; child != nil; child = find(state, child.node.next) {
                switch layout.direction {
                    case .COL: child.shape.absolute.y += align.y
                    case .ROW: child.shape.absolute.x += align.x
                }
            }
        }

        case .SPACE_APART: {
            align /= f32(count - 1)
            space := child.shape.absolute.xy

            for ; child != nil; child = find(state, child.node.next) {
                switch layout.direction {
                    case .COL: {
                        child.shape.absolute.y = space.y

                        space.y += child.shape.absolute.w + align.y
                        space.y += layout.between
                    }

                    case .ROW: {
                        child.shape.absolute.x = space.x

                        space.x += child.shape.absolute.z + align.x
                        space.x += layout.between
                    }
                }
            }
        }

        case .SPACE_EVENLY: {
            align /= f32(count + 1)
            space := child.shape.absolute.xy + align

            for ; child != nil; child = find(state, child.node.next) {
                switch layout.direction {
                    case .COL: {
                        child.shape.absolute.y = space.y

                        space.y += child.shape.absolute.w + align.y
                        space.y += layout.between
                    }

                    case .ROW: {
                        child.shape.absolute.x = space.x

                        space.x += child.shape.absolute.z + align.x
                        space.x += layout.between
                    }
                }
            }
        }

        case .SPACE_AROUND: {
            align /= f32(count * 2)
            space := child.shape.absolute.xy + align

            for ; child != nil; child = find(state, child.node.next) {
                switch layout.direction {
                    case .COL: {
                        child.shape.absolute.y = space.y

                        space.y += child.shape.absolute.w + align.y * 2
                        space.y += layout.between
                    }

                    case .ROW: {
                        child.shape.absolute.x = space.x

                        space.x += child.shape.absolute.z + align.x * 2
                        space.x += layout.between
                    }
                }
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
            compute_tree_size(state, self)
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
            compute_tree_pos(state, self)
        }
    }
}

//
//
//
update_layout :: proc(state: ^State, size: [2]f32)
{
    self := find(state, state.root)

    if self != nil {
        self.shape.offset.zw = size

        compute_size(state, self)
        compute_pos(state, self)
    }
}

//
//
//
compute_hover :: proc(state: ^State, self: ^Element, index: int, point: [2]f32) -> bool
{
    if self == nil { return false }

    point_in_rect(self.shape.absolute, point) or_return

    other := self.node.first
    child := find(state, other)

    for child != nil {
        if compute_hover(state, child, other, point) {
            return true
        }

        other = child.node.next
        child = find(state, other)
    }

    state.hover = index

    return true
}

//
//
//
update_hover :: proc(state: ^State, point: [2]f32)
{
    self := find(state, state.root)

    state.hover = 0

    if self != nil {
        compute_hover(state, self, state.root, point)
    }
}

//
//
//
update_focus :: proc(state: ^State, step: [2]bool)
{
    focus := state.focus

    focus = min(focus + int(step.x), len(state.elems))
    focus = max(focus - int(step.y), 1)

    state.focus = focus
}

//
//
//
point_in_rect :: proc(rect: [4]f32, point: [2]f32) -> bool
{
    return rect.x <= point.x && point.x <= rect.x + rect.z &&
           rect.y <= point.y && point.y <= rect.y + rect.w
}
