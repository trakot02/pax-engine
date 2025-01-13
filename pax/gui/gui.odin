package gui

import "core:log"

import pax "../"
import res "../res"

Direction :: enum
{
    ROW, COL
}

Alignment :: enum
{
    //
    // Each item is placed tightly at the beginning of the container.
    //
    ALIGN_BEGIN,

    //
    // Each item is placed tightly at the center of the container.
    //
    ALIGN_CENTER,

    //
    // Each item is placed tightly at the end of the container.
    //
    ALIGN_END,

    //
    // Each item is placed at the maximum possible distance from its brothers.
    //
    SPACE_APART,

    //
    // Each item is placed at the maximum possible distance from its brothers and
    // the group's sides.
    //
    SPACE_EVENLY,

    //
    // Each item is placed with the maximum possible space around both its sides.
    //
    SPACE_AROUND,

    //
    // Each item fills a part of the group, by default 1/n-th.
    //
    FILL,
}

Node :: struct
{
    //
    // Slot of the element's parent. If zero, the element is a root.
    //
    parent: int,

    //
    // Slot of the element's previous brother. If zero, the element is the first
    // child of its parent.
    //
    prev: int,

    //
    // Slot of the element's next brother. If zero, the element is the last child
    // of its parent.
    //
    next: int,

    //
    // Slot of the element's first child. If zero, so is "last", and the element
    // is a leaf. If the element has a single child "first" is equal to "last".
    //
    first: int,

    //
    // Slot of the element's last child. If zero, so is "first", and the element
    // is a leaf. If the element has a single child "first" is equal to "last".
    //
    last: int,
}

Shape :: struct
{
    //
    // Absolute bounds computed by the system used to draw and interact with
    // the element.
    //
    // Note: These bounds shouldn't be manually altered.
    //
    bounds: [4]f32,

    //
    // Point around which the element's position is computed. Especially useful
    // to center or align the element to a specific side of its parent. If the
    // element has no parent, "origin" doesn't affect the result.
    //
    origin: [2]f32,

    //
    //
    //
    offset: [4]f32,

    //
    //
    //
    factor: [4]f32,
}

Style :: struct
{
    //
    //
    //
    fill: [4]u8,
}

Group :: union
{
    List_Group, Flex_Group, Image_Group, Text_Group
}

Handle :: struct
{
    using node:  ^Node,
    using shape: ^Shape,
    using style: ^Style,

    group: ^Group,

    //
    // Unique identifier of the element used to reference it inside the system.
    //
    slot: int,
}

Element :: struct
{
    origin: [2]f32,
    offset: [4]f32,
    factor: [4]f32,
    fill:   [4]u8,
    group:  Group,
}

State :: struct
{
    //
    // Tracks which element is the root.
    //
    root: int,

    //
    // Tracks which element is active in the current step.
    //
    active: int,

    //
    // Tracks which elements are targets in the current and last steps.
    //
    target: [2]int,

    //
    // Tracks the position of the cursor.
    //
    cursor: [2]f32,

    //
    // Tracks the last movement of the cursor.
    //
    delta: [2]f32,

    //
    //
    //
    textures: ^res.Holder(res.Texture),

    //
    //
    //
    fonts: ^res.Holder(res.Font),

    //
    // Contains all the nodes.
    //
    nodes: [dynamic]Node,

    //
    // Contains all the shapes.
    //
    shapes: [dynamic]Shape,

    //
    //
    //
    styles: [dynamic]Style,

    //
    //
    //
    groups: [dynamic]Group,
}

//
//
//
init :: proc(state: ^State, textures: ^res.Holder(res.Texture), fonts: ^res.Holder(res.Font), allocator := context.allocator)
{
    state.nodes  = make([dynamic]Node,  allocator)
    state.shapes = make([dynamic]Shape, allocator)
    state.styles = make([dynamic]Style, allocator)
    state.groups = make([dynamic]Group, allocator)

    state.textures = textures
    state.fonts    = fonts
}

//
//
//
destroy :: proc(state: ^State)
{
    delete(state.groups)
    delete(state.styles)
    delete(state.shapes)
    delete(state.nodes)

    state.root   = 0
    state.active = 0
    state.target = {}
    state.nodes  = {}
    state.shapes = {}
    state.styles = {}
    state.groups = {}

    state.textures = nil
    state.fonts    = nil
}

//
//
//
find_texture :: proc(state: ^State, slot: int) -> res.Handle(res.Texture)
{
    return res.holder_find(state.textures, slot)
}

//
//
//
find_font :: proc(state: ^State, slot: int) -> res.Handle(res.Font)
{
    return res.holder_find(state.fonts, slot)
}

//
//
//
find :: proc(state: ^State, slot: int) -> Handle
{
    handle := Handle {}
    index  := slot - 1

    if 0 <= index && index < len(state.nodes) {
        handle.slot  = slot
        handle.node  = &state.nodes[index]
        handle.shape = &state.shapes[index]
        handle.style = &state.styles[index]
        handle.group = &state.groups[index]
    }

    return handle
}

//
//
//
find_parent :: proc(state: ^State, handle: Handle) -> Handle
{
    if handle.slot != 0 {
        return find(state, handle.node.parent)
    }

    return {}
}

//
//
//
find_prev :: proc(state: ^State, handle: Handle) -> Handle
{
    if handle.slot != 0 {
        return find(state, handle.node.prev)
    }

    return {}
}

//
//
//
find_next :: proc(state: ^State, handle: Handle) -> Handle
{
    if handle.slot != 0 {
        return find(state, handle.node.next)
    }

    return {}
}

//
//
//
find_first :: proc(state: ^State, handle: Handle) -> Handle
{
    if handle.slot != 0 {
        return find(state, handle.node.first)
    }

    return {}
}

//
//
//
find_last :: proc(state: ^State, handle: Handle) -> Handle
{
    if handle.slot != 0 {
        return find(state, handle.node.last)
    }

    return {}
}

//
//
//
count_children :: proc(state: ^State, handle: Handle) -> int
{
    item  := find_first(state, handle)
    count := 0

    for ; item.slot != 0; item = find_next(state, item) {
        count += 1
    }

    return count
}

//
//
//
insert_root :: proc(state: ^State, element: Element) -> (int, bool)
{
    index := len(state.nodes)

    if state.root != 0 { return 0, false }

    _, error := append(&state.nodes, Node {})

    if error == nil {
        _, error = append(&state.shapes, Shape {
            origin = element.origin,
            offset = element.offset,
            factor = element.factor,
        })
    }

    if error == nil {
        _, error = append(&state.styles, Style {
            fill = element.fill
        })
    }

    if error == nil {
        _, error = append(&state.groups, element.group)
    }

    if error != nil {
        resize(&state.nodes,  index)
        resize(&state.shapes, index)
        resize(&state.styles, index)
        resize(&state.groups, index)

        log.errorf("GUI: Unable to insert root element %v",
            element)

        return 0, false
    }

    handle := find(state, index + 1)

    if handle.slot == 0 { return 0, false }

    state.root = handle.slot

    return handle.slot, true
}

//
//
//
insert_child :: proc(state: ^State, parent: int, element: Element) -> (int, bool)
{
    index := len(state.nodes)

    if parent <= 0 || parent > index { return 0, false }

    _, error := append(&state.nodes, Node {parent = parent})

    if error == nil {
        _, error = append(&state.shapes, Shape {
            origin = element.origin,
            offset = element.offset,
            factor = element.factor,
        })
    }

    if error == nil {
        _, error = append(&state.styles, Style {
            fill = element.fill
        })
    }

    if error == nil {
        _, error = append(&state.groups, element.group)
    }

    if error != nil {
        resize(&state.nodes,  index)
        resize(&state.shapes, index)
        resize(&state.styles, index)
        resize(&state.groups, index)

        log.errorf("GUI: Unable to insert element %v",
            element)

        return 0, false
    }

    handle := find(state, index + 1)
    parent := find(state, parent)

    if handle.slot == 0 { return 0, false }

    last  := find_last(state, parent)
    first := find_first(state, parent)

    if first.slot == 0 { parent.node.first = handle.slot }
    if last.slot  != 0 { last.node.next    = handle.slot }

    handle.node.prev = parent.node.last
    parent.node.last = handle.slot

    return handle.slot, true
}

//
//
//
flush :: proc(state: ^State)
{
    state.root = 0

    clear(&state.nodes)
    clear(&state.shapes)
    clear(&state.styles)
    clear(&state.groups)
}

//
//
//
update :: proc(state: ^State, delta: [2]f32)
{
    state.target[0] = state.target[1]
    state.target[1] = 0

    state.delta   = delta
    state.cursor += delta
}

//
//
//
layout :: proc(state: ^State)
{
    handle := find(state, state.root)

    if handle.slot != 0 {
        compute_size(state, handle)
        compute_pos(state, handle)
    }
}

//
//
//
compute_size :: proc(state: ^State, handle: Handle)
{
    switch &group in handle.group {
        case List_Group:  compute_list_size(state, handle, &group)
        case Flex_Group:  compute_flex_size(state, handle, &group)
        case Image_Group: compute_image_size(state, handle, &group)
        case Text_Group:  compute_text_size(state, handle, &group)

        case nil: {
            compute_own_size(state, handle)
            compute_rec_size(state, handle)
        }
    }
}

//
//
//
compute_part :: proc(state: ^State, handle: Handle, size: [2]f32)
{
    switch &group in handle.group {
        case List_Group:  compute_list_part(state, handle, &group, size)
        case Flex_Group:  compute_flex_part(state, handle, &group, size)
        case Image_Group: compute_image_part(state, handle, &group, size)
        case Text_Group:  compute_text_part(state, handle, &group, size)

        case nil: {
            compute_own_part(state, handle, size)
            compute_rec_size(state, handle)
        }
    }
}

//
//
//
compute_pos :: proc(state: ^State, handle: Handle)
{
    switch &group in handle.group {
        case List_Group:  compute_list_pos(state, handle, &group)
        case Flex_Group:  compute_flex_pos(state, handle, &group)
        case Image_Group: compute_image_pos(state, handle, &group)
        case Text_Group:  compute_text_pos(state, handle, &group)

        case nil: {
            compute_own_pos(state, handle)
            compute_rec_pos(state, handle)
        }
    }
}

//
//
//
compute_own_size :: proc(state: ^State, handle: Handle)
{
    parent := find_parent(state, handle)

    handle.bounds.zw = handle.offset.zw

    if parent.slot != 0 {
        handle.bounds.zw += handle.factor.zw *
            parent.bounds.zw
    }
}

//
//
//
compute_own_part :: proc(state: ^State, handle: Handle, size: [2]f32)
{
    handle.bounds.zw = handle.offset.zw + handle.factor.zw * size
}

//
//
//
compute_rec_size :: proc(state: ^State, handle: Handle)
{
    item := find_first(state, handle)

    for ; item.slot != 0; item = find_next(state, item) {
        compute_size(state, item)
    }
}

//
//
//
compute_own_pos :: proc(state: ^State, handle: Handle)
{
    parent := find_parent(state, handle)

    handle.bounds.xy  = handle.offset.xy
    handle.bounds.xy -= handle.origin * handle.bounds.zw

    if parent.slot != 0 {
        handle.bounds.xy += handle.factor.xy *
            parent.bounds.zw + parent.bounds.xy
    }
}

//
//
//
compute_rec_pos :: proc(state: ^State, handle: Handle)
{
    item := find_first(state, handle)

    for ; item.slot != 0; item = find_next(state, item) {
        compute_pos(state, item)
    }
}

//
//
//
is_active :: proc(state: ^State, handle: Handle) -> bool
{
    if handle.slot != 0 {
        return state.active == handle.slot
    }

    return false
}

//
//
//
set_active :: proc(state: ^State, handle: Handle)
{
    state.active = handle.slot
}

//
//
//
is_target :: proc(state: ^State, handle: Handle) -> bool
{
    if handle.slot != 0 {
        return state.target[0] == handle.slot
    }

    return false
}

//
//
//
set_target :: proc(state: ^State, handle: Handle)
{
    state.target[1] = handle.slot
}

//
//
//
point_in_rect :: proc(rect: [4]f32, point: [2]f32) -> bool
{
    return rect.x <= point.x && point.x <= rect.x + rect.z &&
           rect.y <= point.y && point.y <= rect.y + rect.w
}
