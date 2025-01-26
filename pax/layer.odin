package pax

import "core:log"

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
    proc_draw:  proc(self: rawptr),
}

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
    proc_draw  = proc(self: rawptr) {},
}

Layer_Stack :: struct
{
    items: [dynamic]Layer,
}

Layer_Stack_It :: struct
{
    stack: ^Layer_Stack,
    index: int,
}

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

layer_draw :: proc(self: ^Layer)
{
    self.proc_draw(self.self)
}

layer_stack_init :: proc(self: ^Layer_Stack, allocator := context.allocator)
{
    self.items = make([dynamic]Layer, allocator)
}

layer_stack_destroy :: proc(self: ^Layer_Stack)
{
    delete(self.items)

    self.items = {}
}

layer_stack_clear :: proc(self: ^Layer_Stack)
{
    clear(&self.items)
}

layer_stack_insert :: proc(self: ^Layer_Stack, value: Layer) -> Handle(Layer)
{
    _, error := append(&self.items, value)

    if error != nil {
        log.errorf("Layer_Stack: Unable to insert layer")

        return  {}
    }

    return layer_stack_find(self, len(self.items))
}

layer_stack_remove :: proc(self: ^Layer_Stack) -> (Layer, bool)
{
    count := len(self.items) - 1

    if count < 0 { return {}, false }

    value := self.items[count]

    resize(&self.items, count)

    return value, true
}

layer_stack_find :: proc(self: ^Layer_Stack, slot: int) -> Handle(Layer)
{
    handle := Handle(Layer) {}

    if slot <= 0 || slot > len(self.items) {
        return handle
    }

    handle.slot  = slot
    handle.value = &self.items[slot - 1]

    return handle
}

layer_stack_size :: proc(self: ^Layer_Stack) -> int
{
    return len(self.items)
}

layer_stack_it :: proc(self: ^Layer_Stack) -> Layer_Stack_It
{
    return {
        stack = self,
        index = 1,
    }
}

layer_stack_next :: proc(self: ^Layer_Stack_It) -> (^Layer, int, bool)
{
    handle := Handle(Layer) {}

    if self.index > layer_stack_size(self.stack) {
        return nil, 0, false
    }

    handle      = layer_stack_find(self.stack, self.index)
    self.index += 1

    return handle.value, handle.slot, handle.slot != 0
}

layer_stack_next_reverse :: proc(self: ^Layer_Stack_It) -> (^Layer, int, bool)
{
    handle := Handle(Layer) {}
    size   := layer_stack_size(self.stack)

    if self.index > size {
        return nil, 0, false
    }

    handle      = layer_stack_find(self.stack, size - self.index + 1)
    self.index += 1

    return handle.value, handle.slot, handle.slot != 0
}
