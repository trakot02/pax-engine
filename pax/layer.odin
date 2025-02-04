package pax

import "core:log"

//
// Variables
//

LAYER := Layer {
    proc_start = proc(self: rawptr, data: rawptr) -> bool {
        return true
    },

    proc_stop  = proc(self: rawptr) {},
    proc_enter = proc(self: rawptr) {},
    proc_leave = proc(self: rawptr) {},

    proc_event = proc(self: rawptr, event: Event) -> bool {
        return true
    },

    proc_frame = proc(self: rawptr, frame_time: f32) {},
    proc_step  = proc(self: rawptr, delta_time: f32) {},
    proc_paint = proc(self: rawptr) {},
}

//
// Definitions
//

Layer :: struct
{
    self: rawptr,

    proc_start: proc(self: rawptr, data: rawptr) -> bool,
    proc_stop:  proc(self: rawptr),
    proc_enter: proc(self: rawptr),
    proc_leave: proc(self: rawptr),
    proc_event: proc(self: rawptr, event: Event) -> bool,
    proc_frame: proc(self: rawptr, frame_time: f32),
    proc_step:  proc(self: rawptr, delta_time: f32),
    proc_paint: proc(self: rawptr),
}

Layer_Stack :: struct
{
    // Dense array of layers.
    items: [dynamic]Layer,
}

Layer_Stack_Iter :: struct
{
    stack: ^Layer_Stack,
    index: int,
}

//
// Functions
//

layer_start :: proc(self: ^Layer, data: rawptr) -> bool
{
    return self.proc_start(self.self, data)
}

layer_stop :: proc(self: ^Layer)
{
    self.proc_stop(self.self)
}

layer_enter :: proc(self: ^Layer)
{
    self.proc_enter(self.self)
}

layer_leave :: proc(self: ^Layer)
{
    self.proc_leave(self.self)
}

layer_event :: proc(self: ^Layer, event: Event) -> bool
{
    return self.proc_event(self.self, event)
}

layer_frame :: proc(self: ^Layer, frame_time: f32)
{
    self.proc_frame(self.self, frame_time)
}

layer_step :: proc(self: ^Layer, delta_time: f32)
{
    self.proc_step(self.self, delta_time)
}

layer_paint :: proc(self: ^Layer)
{
    self.proc_paint(self.self)
}

layer_stack_init :: proc(allocator := context.allocator) -> Layer_Stack
{
    return Layer_Stack {
        items = make([dynamic]Layer, allocator)
    }
}

layer_stack_destroy :: proc(self: ^Layer_Stack)
{
    delete(self.items)

    self.items = {}
}

layer_stack_len :: proc(self: ^Layer_Stack) -> int
{
    return len(self.items)
}

layer_stack_clear :: proc(self: ^Layer_Stack)
{
    clear(&self.items)
}

layer_stack_insert :: proc(self: ^Layer_Stack, value: Layer) -> int
{
    _, error := append(&self.items, value)

    if error != nil {
        log.errorf("Layer_Stack: Unable to insert layer")

        return  {}
    }

    return len(self.items)
}

layer_stack_remove :: proc(self: ^Layer_Stack) -> (Layer, bool)
{
    count := len(self.items)

    if count <= 0 { return {}, false }

    index := count - 1
    value := self.items[index]

    resize(&self.items, index)

    return value, true
}

layer_stack_find :: proc(self: ^Layer_Stack, ident: int) -> Handle(Layer)
{
    handle := Handle(Layer) {}

    if ident <= 0 || ident > len(self.items) {
        return handle
    }

    handle.ident = ident
    handle.value = &self.items[ident - 1]

    return handle
}

layer_stack_iter :: proc(self: ^Layer_Stack) -> Layer_Stack_Iter
{
    return Layer_Stack_Iter {
        stack = self,
    }
}

layer_stack_next_above :: proc(self: ^Layer_Stack_Iter) -> (^Layer, int, bool)
{
    count := len(self.stack.items)

    if self.index < 0 || self.index >= count {
        return nil, 0, false
    }

    value := &self.stack.items[self.index]
    ident := self.index + 1

    self.index = ident

    return value, ident, true
}

layer_stack_next_below :: proc(self: ^Layer_Stack_Iter) -> (^Layer, int, bool)
{
    count := len(self.stack.items)

    if self.index < 0 || self.index >= count {
        return nil, 0, false
    }

    ident := self.index + 1
    value := &self.stack.items[count - ident]

    self.index = ident

    return value, ident, true
}
