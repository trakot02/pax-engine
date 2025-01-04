package pax

import "core:log"

GUI_Node :: struct
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

GUI_Shape :: struct
{
    //
    // Fixed offsets used to compute an element's absolute bounds.
    //
    offset: [4]f32,

    //
    // Point around which the element's bounds are computed. Especially useful
    // to center or align an element to a specific side of its parent. By default
    // if the element has no parent, "origin" has no meaning.
    //
    // Note: Each layout can apply a different meaning to "origin", so refer to
    //       that layout's specific notes.
    //
    origin: [2]f32,

    //
    // Bounds relative to the element's parent. By default if the element has
    // no parent, "relative" has no meaning.
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

    //
    // Color applied to the element's shape.
    //
    color: [4]u8,
}

GUI_Group :: union
{
    GUI_List_Group, GUI_Flex_Group,
}

GUI_List_Group :: struct
{
    //
    // GUI_Direction of the container.
    //
    direction: GUI_Direction,

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

GUI_Flex_Group :: struct
{
    //
    // Defines the direction of the container.
    //
    direction: GUI_Direction,

    //
    // Defines how each child should be placed in the direction of the container.
    //
    placement: GUI_Placement,

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

GUI_Direction :: enum
{
    ROW, COL
}

GUI_Placement :: enum
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

GUI_Input :: struct
{
    //
    //
    //
    instance: rawptr,

    //
    //
    //
    call_proc: rawptr,
}

GUI_Handle :: struct
{
    //
    // Identifier of the element.
    //
    number: int,

    //
    //
    //
    node: ^GUI_Node,

    //
    //
    //
    shape: ^GUI_Shape,

    //
    //
    //
    group: ^GUI_Group,

    //
    //
    //
    input: ^GUI_Input,
}

Recipe :: struct
{
    //
    //
    //
    shape: GUI_Shape,

    //
    //
    //
    group: GUI_Group,

    //
    //
    //
    input: GUI_Input,
}

GUI_Layer :: struct
{
    //
    // Tracks which element is the root.
    //
    // Note: The root element should be specified with the
    //       "gui_append_root" procedure exactly once.
    //
    root: int,

    //
    // Tracks which element should receive drag events.
    //
    active: int,

    //
    // Tracks which element should receive press and release
    // events.
    //
    focus: int,

    //
    // Track which element should receive focus and scroll
    // events.
    //
    hover: int,

    //
    // Contains all the nodes.
    //
    nodes: [dynamic]GUI_Node,

    //
    // Contains all the shapes.
    //
    shapes: [dynamic]GUI_Shape,

    //
    // Contains all the groups.
    //
    groups: [dynamic]GUI_Group,

    //
    // Contains all the inputs.
    //
    inputs: [dynamic]GUI_Input,
}

gui_input_from_proc :: proc(call: proc(^GUI_Layer, int)) -> GUI_Input
{
    return {
        call_proc = auto_cast call,
    }
}

gui_input_from_pair :: proc(instance: ^$T, call: proc(^GUI_Layer, int, ^T)) -> GUI_Input
{
    return {
        instance  = auto_cast instance,
        call_proc = auto_cast call,
    }
}

gui_input_from :: proc {
    gui_input_from_proc,
    gui_input_from_pair,
}

//
//
//
gui_init :: proc(layer: ^GUI_Layer, allocator := context.allocator)
{
    layer.nodes  = make([dynamic]GUI_Node,  allocator)
    layer.shapes = make([dynamic]GUI_Shape, allocator)
    layer.groups = make([dynamic]GUI_Group, allocator)
    layer.inputs = make([dynamic]GUI_Input, allocator)
}

//
//
//
gui_destroy :: proc(layer: ^GUI_Layer)
{
    delete(layer.inputs)
    delete(layer.groups)
    delete(layer.shapes)
    delete(layer.nodes)

    layer.root    = 0
    layer.active  = 0
    layer.focus   = 0
    layer.hover   = 0
    layer.nodes   = {}
    layer.shapes  = {}
    layer.groups  = {}
    layer.inputs  = {}
}

//
//
//
gui_clear :: proc(layer: ^GUI_Layer)
{
    clear(&layer.inputs)
    clear(&layer.groups)
    clear(&layer.shapes)
    clear(&layer.nodes)

    layer.root   = 0
    layer.active = 0
    layer.focus  = 0
    layer.hover  = 0
}

//
//
//
gui_find :: proc(layer: ^GUI_Layer, number: int) -> GUI_Handle
{
    result := GUI_Handle {}
    index  := number - 1

    if 0 <= index && index < len(layer.nodes) {
        result.number = number
        result.node   = &layer.nodes[index]
        result.shape  = &layer.shapes[index]
        result.group  = &layer.groups[index]
        result.input  = &layer.inputs[index]
    }

    return result
}

//
//
//
gui_parent :: proc(layer: ^GUI_Layer, node: ^GUI_Node) -> GUI_Handle
{
    if node != nil {
        return gui_find(layer, node.parent)
    }

    return {}
}

//
//
//
gui_first :: proc(layer: ^GUI_Layer, node: ^GUI_Node) -> GUI_Handle
{
    if node != nil {
        return gui_find(layer, node.first)
    }

    return {}
}

//
//
//
gui_last :: proc(layer: ^GUI_Layer, node: ^GUI_Node) -> GUI_Handle
{
    if node != nil {
        return gui_find(layer, node.last)
    }

    return {}
}

//
//
//
gui_prev :: proc(layer: ^GUI_Layer, node: ^GUI_Node) -> GUI_Handle
{
    if node != nil {
        return gui_find(layer, node.prev)
    }

    return {}
}

//
//
//
gui_next :: proc(layer: ^GUI_Layer, node: ^GUI_Node) -> GUI_Handle
{
    if node != nil {
        return gui_find(layer, node.next)
    }

    return {}
}

//
//
//
gui_children :: proc(layer: ^GUI_Layer, node: ^GUI_Node) -> int
{
    if node == nil { return 0 }

    child := gui_find(layer, node.first)
    count := 0

    for ; child.number != 0; count += 1 {
        child = gui_next(layer, child.node)
    }

    return count
}

gui_append_root :: proc(layer: ^GUI_Layer, recipe: Recipe) -> int
{
    count := len(layer.nodes)

    if layer.root != 0 { return 0 }

    _, error := append(&layer.nodes, GUI_Node {})

    if error == nil { _, error = append(&layer.shapes, recipe.shape) }
    if error == nil { _, error = append(&layer.groups, recipe.group) }
    if error == nil { _, error = append(&layer.inputs, recipe.input) }

    if error != nil {
        resize(&layer.nodes,  count)
        resize(&layer.shapes, count)
        resize(&layer.groups, count)
        resize(&layer.inputs, count)

        log.errorf("GUI: Unable to insert root element = %v, %v, %v",
            recipe.shape, recipe.group, recipe.input)

        return 0
    }

    self       := gui_find(layer, count + 1)
    layer.root  = self.number

    return self.number
}

//
//
//
gui_append_child :: proc(layer: ^GUI_Layer, parent: int, recipe: Recipe) -> int
{
    count := len(layer.nodes)

    if parent <= 0 || parent > count { return 0 }

    _, error := append(&layer.nodes, GUI_Node { parent = parent })

    if error == nil { _, error = append(&layer.shapes, recipe.shape) }
    if error == nil { _, error = append(&layer.groups, recipe.group) }
    if error == nil { _, error = append(&layer.inputs, recipe.input) }

    if error != nil {
        resize(&layer.nodes,  count)
        resize(&layer.shapes, count)
        resize(&layer.groups, count)
        resize(&layer.inputs, count)

        log.errorf("GUI: Unable to insert element = %v, %v, %v",
            recipe.shape, recipe.group, recipe.input)

        return 0
    }

    self   := gui_find(layer, count + 1)
    parent := gui_parent(layer, self.node)

    if parent.number != 0 {
        last  := gui_last(layer, parent.node)
        first := gui_first(layer, parent.node)

        if first.number == 0 { parent.node.first = self.number }
        if last.number  != 0 { last.node.next    = self.number }

        self.node.prev   = parent.node.last
        parent.node.last = self.number
    }

    return self.number
}

//
//
//
gui_calc_size :: proc(layer: ^GUI_Layer, node: ^GUI_Node, shape: ^GUI_Shape, group: ^GUI_Group)
{
    if node == nil || shape == nil { return }

    switch &type in group {
        case GUI_List_Group: gui_calc_list_size(layer, node, shape, type)
        case GUI_Flex_Group: gui_calc_flex_size(layer, node, shape, type)

        case nil: {
            gui_calc_own_size(layer, node, shape)
            gui_calc_rec_size(layer, node)
        }
    }
}

//
//
//
gui_calc_pos :: proc(layer: ^GUI_Layer, node: ^GUI_Node, shape: ^GUI_Shape, group: ^GUI_Group)
{
    if node == nil || shape == nil { return }

    switch &type in group {
        case GUI_List_Group: gui_calc_list_pos(layer, node, shape, type)
        case GUI_Flex_Group: gui_calc_flex_pos(layer, node, shape, type)

        case nil: {
            gui_calc_own_pos(layer, node, shape)
            gui_calc_rec_pos(layer, node)
        }
    }
}

//
//
//
gui_calc_own_size :: proc(layer: ^GUI_Layer, node: ^GUI_Node, shape: ^GUI_Shape)
{
    if node == nil || shape == nil { return }

    parent := gui_parent(layer, node)

    shape.absolute.zw = shape.offset.zw

    if parent.number != 0 {
        shape.absolute.zw += parent.shape.absolute.zw *
            shape.relative.zw
    }
}

//
//
//
gui_calc_rec_size :: proc(layer: ^GUI_Layer, node: ^GUI_Node)
{
    if node == nil { return }

    child := gui_first(layer, node)

    for ; child.number != 0; child = gui_next(layer, child.node) {
        gui_calc_size(layer, child.node, child.shape, child.group)
    }
}

//
//
//
gui_calc_own_pos :: proc(layer: ^GUI_Layer, node: ^GUI_Node, shape: ^GUI_Shape)
{
    if node == nil || shape == nil { return }

    parent := gui_parent(layer, node)

    shape.absolute.xy  = shape.offset.xy
    shape.absolute.xy -= shape.origin * shape.absolute.zw

    if parent.number != 0 {
        shape.absolute.xy += parent.shape.absolute.zw *
            shape.relative.xy + parent.shape.absolute.xy
    }
}

//
//
//
gui_calc_rec_pos :: proc(layer: ^GUI_Layer, node: ^GUI_Node)
{
    if node == nil { return }

    child := gui_first(layer, node)

    for ; child.number != 0; child = gui_next(layer, child.node) {
        gui_calc_pos(layer, child.node, child.shape, child.group)
    }
}

//
//
//
gui_calc_list_size :: proc(layer: ^GUI_Layer, node: ^GUI_Node, shape: ^GUI_Shape, group: GUI_List_Group)
{
    if node == nil || shape == nil { return }

    rect  := shape.offset
    child := gui_first(layer, node)
    count := 0

    switch group.direction {
        case .COL: rect.w = 0
        case .ROW: rect.z = 0
    }

    for ; child.number != 0; child = gui_next(layer, child.node) {
        gui_calc_size(layer, child.node, child.shape, child.group)

        switch group.direction {
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
        switch group.direction {
            case .COL: rect.w += group.between * f32(count - 1)
            case .ROW: rect.z += group.between * f32(count - 1)
        }
    }

    if group.stretch == true {
        child = gui_first(layer, node)

        for ; child.number != 0; child = gui_next(layer, child.node) {
            switch group.direction {
                case .COL: child.shape.absolute.z = rect.z
                case .ROW: child.shape.absolute.w = rect.w
            }
        }
    }

    shape.absolute.zw = rect.zw
}

//
//
//
gui_calc_list_pos :: proc(layer: ^GUI_Layer, node: ^GUI_Node, shape: ^GUI_Shape, group: GUI_List_Group)
{
    if node == nil || shape == nil { return }

    gui_calc_own_pos(layer, node, shape)

    rect  := shape.absolute
    child := gui_first(layer, node)

    for ; child.number != 0; child = gui_next(layer, child.node) {
        child.shape.absolute.xy = rect.xy

        switch group.direction {
            case .COL: {
                child.shape.absolute.x -= child.shape.origin.x   * child.shape.absolute.z
                child.shape.absolute.x += child.shape.relative.x * shape.absolute.z

                rect.y  = child.shape.absolute.y
                rect.y += child.shape.absolute.w + group.between
            }

            case .ROW: {
                child.shape.absolute.y -= child.shape.origin.y   * child.shape.absolute.w
                child.shape.absolute.y += child.shape.relative.y * shape.absolute.w

                rect.x  = child.shape.absolute.x
                rect.x += child.shape.absolute.z + group.between
            }
        }

        gui_calc_rec_pos(layer, child.node)
    }
}

//
//
//
gui_calc_flex_size :: proc(layer: ^GUI_Layer, node: ^GUI_Node, shape: ^GUI_Shape, group: GUI_Flex_Group)
{
    if node == nil || shape == nil { return }

    gui_calc_own_size(layer, node, shape)

    part  := shape.absolute
    count := gui_children(layer, node)

    if count > 1 {
        switch group.direction {
            case .ROW: {
                part.z -= group.between * f32(count - 1)
                part.z /= f32(count)
            }

            case .COL: {
                part.w -= group.between * f32(count - 1)
                part.w /= f32(count)
            }
        }
    }

    child := gui_first(layer, node)

    for ; child.number != 0; child = gui_next(layer, child.node) {
        child.shape.absolute.zw = child.shape.offset.zw + part.zw *
            child.shape.relative.zw

        if group.placement == .FILL {
            switch group.direction {
                case .COL: child.shape.absolute.w = part.w
                case .ROW: child.shape.absolute.z = part.z
            }
        }
    }

    if group.stretch == true {
        child = gui_first(layer, node)

        for ; child.number != 0; child = gui_next(layer, child.node) {
            switch group.direction {
                case .COL: child.shape.absolute.z = part.z
                case .ROW: child.shape.absolute.w = part.w
            }
        }
    }
}

//
//
//
gui_calc_flex_pos :: proc(layer: ^GUI_Layer, node: ^GUI_Node, shape: ^GUI_Shape, group: GUI_Flex_Group)
{
    if node == nil || shape == nil { return }

    gui_calc_own_pos(layer, node, shape)

    part  := shape.absolute
    child := gui_first(layer, node)
    count := 0

    for ; child.number != 0; child = gui_next(layer, child.node) {
        child.shape.absolute.xy = part.xy

        switch group.direction {
            case .COL: {
                child.shape.absolute.x -= child.shape.origin.x   * child.shape.absolute.z
                child.shape.absolute.x += child.shape.relative.x * shape.absolute.z

                part.y  = child.shape.absolute.y
                part.y += child.shape.absolute.w + group.between
            }

            case .ROW: {
                child.shape.absolute.y -= child.shape.origin.y   * child.shape.absolute.w
                child.shape.absolute.y += child.shape.relative.y * shape.absolute.w

                part.x  = child.shape.absolute.x
                part.x += child.shape.absolute.z + group.between
            }
        }

        count += 1
    }

    child = gui_last(layer, node)

    if child.number == 0 { return }

    align := shape.absolute.xy + shape.absolute.zw -
        child.shape.absolute.xy - child.shape.absolute.zw

    child = gui_first(layer, node)

    #partial switch group.placement {
        case .ALIGN_CENTER: {
            for ; child.number != 0; child = gui_next(layer, child.node) {
                switch group.direction {
                    case .COL: child.shape.absolute.y += align.y / 2
                    case .ROW: child.shape.absolute.x += align.x / 2
                }
            }
        }

        case .ALIGN_END: {
            for ; child.number != 0; child = gui_next(layer, child.node) {
                switch group.direction {
                    case .COL: child.shape.absolute.y += align.y
                    case .ROW: child.shape.absolute.x += align.x
                }
            }
        }

        case .SPACE_APART: {
            align /= f32(count - 1)
            space := child.shape.absolute.xy

            for ; child.number != 0; child = gui_next(layer, child.node) {
                switch group.direction {
                    case .COL: {
                        child.shape.absolute.y = space.y

                        space.y += child.shape.absolute.w + align.y
                        space.y += group.between
                    }

                    case .ROW: {
                        child.shape.absolute.x = space.x

                        space.x += child.shape.absolute.z + align.x
                        space.x += group.between
                    }
                }
            }
        }

        case .SPACE_EVENLY: {
            align /= f32(count + 1)
            space := child.shape.absolute.xy + align

            for ; child.number != 0; child = gui_next(layer, child.node) {
                switch group.direction {
                    case .COL: {
                        child.shape.absolute.y = space.y

                        space.y += child.shape.absolute.w + align.y
                        space.y += group.between
                    }

                    case .ROW: {
                        child.shape.absolute.x = space.x

                        space.x += child.shape.absolute.z + align.x
                        space.x += group.between
                    }
                }
            }
        }

        case .SPACE_AROUND: {
            align /= f32(count * 2)
            space := child.shape.absolute.xy + align

            for ; child.number != 0; child = gui_next(layer, child.node) {
                switch group.direction {
                    case .COL: {
                        child.shape.absolute.y = space.y

                        space.y += child.shape.absolute.w + align.y * 2
                        space.y += group.between
                    }

                    case .ROW: {
                        child.shape.absolute.x = space.x

                        space.x += child.shape.absolute.z + align.x * 2
                        space.x += group.between
                    }
                }
            }
        }
    }
}

//
//
//
gui_calc_hover :: proc(layer: ^GUI_Layer, self: GUI_Handle, point: [2]f32) -> bool
{
    if self.number == 0 { return false }

    point_in_rect(self.shape.absolute, point) or_return

    child := gui_first(layer, self.node)

    for ; child.number != 0; child = gui_next(layer, child.node) {
        if gui_calc_hover(layer, child, point) { return true }
    }

    if self.input.call_proc == nil { return false }

    layer.hover = self.number

    return true
}

//
//
//
gui_update :: proc(layer: ^GUI_Layer, area: [2]f32, point: [2]f32 = {}, step: [3]bool = {})
{
    self  := gui_find(layer, layer.root)
    focus := layer.focus + int(step.x) - int(step.y)

    layer.hover = 0

    if self.number != 0 {
        self.shape.offset.zw = area

        gui_calc_size(layer, self.node, self.shape, self.group)
        gui_calc_pos(layer, self.node, self.shape, self.group)

        gui_calc_hover(layer, self, point)
    }

    layer.focus = focus
    layer.focus = min(layer.focus, len(layer.nodes))
    layer.focus = max(layer.focus, 0)

    if step.z == true { layer.focus = 0 }
}

//
//
//
gui_focused :: proc(layer: ^GUI_Layer, number: int, action: bool) -> bool
{
    if action ==       false { return false }
    if number != layer.hover { return false }

    self  := gui_find(layer, layer.hover)
    focus := layer.focus

    if self.number != 0 {
        layer.focus = layer.hover

        if focus != layer.hover {
            return true
        }
    }

    return false
}

//
//
//
gui_scrolled :: proc(layer: ^GUI_Layer, number: int, action: bool) -> bool
{
    if action ==       false { return false }
    if number != layer.hover { return false }

    self := gui_find(layer, layer.hover)

    if self.number != 0 { return true }

    return false
}

//
//
//
gui_pressed :: proc(layer: ^GUI_Layer, number: int, action: bool) -> bool
{
    if action ==       false { return false }
    if number != layer.focus { return false }

    self := gui_find(layer, layer.focus)

    if self.number != 0 {
        layer.active = layer.focus

        return true
    }

    return false
}

//
//
//
gui_released :: proc(layer: ^GUI_Layer, number: int, action: bool) -> bool
{
    if action ==       false { return false }
    if number != layer.focus { return false }

    self := gui_find(layer, layer.focus)

    if self.number != 0 {
        layer.active = 0

        return true
    }

    return false
}

//
//
//
gui_dragged :: proc(layer: ^GUI_Layer, number: int, action: bool) -> bool
{
    if action ==        false { return false }
    if number != layer.active { return false }

    self := gui_find(layer, layer.active)

    if self.number != 0 { return true }

    return false
}

//
//
//
point_in_rect :: proc(rect: [4]f32, point: [2]f32) -> bool
{
    return rect.x <= point.x && point.x <= rect.x + rect.z &&
           rect.y <= point.y && point.y <= rect.y + rect.w
}
