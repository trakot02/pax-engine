package pax

import "core:log"

//
// Variables
//

SCENE := Scene {
    proc_start = proc(self: rawptr, app: ^App) -> bool {
        return true
    },

    proc_stop  = proc(self: rawptr, app: ^App) {},
    proc_enter = proc(self: rawptr, app: ^App) {},
    proc_leave = proc(self: rawptr, app: ^App) {},

    proc_event = proc(self: rawptr, app: ^App, event: Event) -> bool {
        return true
    },

    proc_tick        = proc(self: rawptr, app: ^App, delta_time: f32) {},
    proc_begin_frame = proc(self: rawptr, app: ^App, frame_time: f32) {},
    proc_end_frame   = proc(self: rawptr, app: ^App, frame_time: f32) {},
}

//
// Definitions
//

Scene :: struct
{
    self: rawptr,

    proc_start:       proc(self: rawptr, app: ^App) -> bool,
    proc_stop:        proc(self: rawptr, app: ^App),
    proc_enter:       proc(self: rawptr, app: ^App),
    proc_leave:       proc(self: rawptr, app: ^App),
    proc_event:       proc(self: rawptr, app: ^App, event: Event) -> bool,
    proc_tick:        proc(self: rawptr, app: ^App, delta_time: f32),
    proc_begin_frame: proc(self: rawptr, app: ^App, frame_time: f32),
    proc_end_frame:   proc(self: rawptr, app: ^App, frame_time: f32),
}

Scene_Stack :: struct
{
    // Dense array of scenes.
    items: [dynamic]Scene,
}

Scene_Stack_Iter :: struct
{
    stack: ^Scene_Stack,
    index: int,
}

//
// Functions
//

scene_start :: proc(self: ^Scene, app: ^App) -> bool
{
    return self.proc_start(self.self, app)
}

scene_stop :: proc(self: ^Scene, app: ^App)
{
    self.proc_stop(self.self, app)
}

scene_enter :: proc(self: ^Scene, app: ^App)
{
    self.proc_enter(self.self, app)
}

scene_leave :: proc(self: ^Scene, app: ^App)
{
    self.proc_leave(self.self, app)
}

scene_event :: proc(self: ^Scene, app: ^App, event: Event) -> bool
{
    return self.proc_event(self.self, app, event)
}

scene_tick :: proc(self: ^Scene, app: ^App, delta_time: f32)
{
    self.proc_tick(self.self, app, delta_time)
}

scene_begin_frame :: proc(self: ^Scene, app: ^App, frame_time: f32)
{
    self.proc_begin_frame(self.self, app, frame_time)
}

scene_end_frame :: proc(self: ^Scene, app: ^App, frame_time: f32)
{
    self.proc_end_frame(self.self, app, frame_time)
}

scene_stack_init :: proc(allocator := context.allocator) -> Scene_Stack
{
    return Scene_Stack {
        items = make([dynamic]Scene, allocator)
    }
}

scene_stack_destroy :: proc(self: ^Scene_Stack)
{
    delete(self.items)

    self.items = {}
}

scene_stack_len :: proc(self: ^Scene_Stack) -> int
{
    return len(self.items)
}

scene_stack_clear :: proc(self: ^Scene_Stack)
{
    clear(&self.items)
}

scene_stack_insert :: proc(self: ^Scene_Stack, value: Scene) -> int
{
    _, error := append(&self.items, value)

    if error != nil {
        log.errorf("Scene_Stack: Unable to insert scene")

        return  {}
    }

    return len(self.items)
}

scene_stack_remove :: proc(self: ^Scene_Stack) -> (Scene, bool)
{
    count := len(self.items)

    if count > 0 {
        index := count - 1
        value := self.items[index]

        resize(&self.items, index)

        return value, true
    }

    return {}, false
}

scene_stack_find :: proc(self: ^Scene_Stack, ident: int) -> ^Scene
{
    if ident > 0 && ident <= len(self.items) {
        return &self.items[ident - 1]
    }

    return nil 
}

scene_stack_iter :: proc(self: ^Scene_Stack) -> Scene_Stack_Iter
{
    return Scene_Stack_Iter {
        stack = self,
    }
}

scene_stack_next_above :: proc(self: ^Scene_Stack_Iter) -> (^Scene, int, bool)
{
    count := len(self.stack.items)

    if self.index >= 0 && self.index < count {
        value := &self.stack.items[self.index]
        ident := self.index + 1

        self.index = ident

        return value, ident, true
    }

    return nil, 0, false
}

scene_stack_next_below :: proc(self: ^Scene_Stack_Iter) -> (^Scene, int, bool)
{
    count := len(self.stack.items)

    if self.index >= 0 && self.index < count { 
        ident := self.index + 1
        value := &self.stack.items[count - ident]

        self.index = ident
    
        return value, ident, true
    }

    return nil, 0, false
}
