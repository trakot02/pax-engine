package pax

import "core:log"
import "core:time"

//
// Definitions
//

App :: struct
{
    input:   Input_State,
    painter: Painter,

    table: Slot_Table(Layer),
    stack: Layer_Stack,
}

App_Config :: struct
{
    first_layer:    int,
    max_frame_rate: int,
    max_frame_skip: int,
}

//
// Functions
//

app_init :: proc(self: ^App, allocator := context.allocator) -> bool
{
    backend_init({320, 180}, "Pax") or_return

    self.table   = slot_table_init(Layer, allocator)
    self.stack   = layer_stack_init(allocator)
    self.painter = painter_init()

    return true
}

app_destroy :: proc(self: ^App)
{
    painter_destroy(&self.painter)

    layer_stack_destroy(&self.stack)
    slot_table_destroy(&self.table)

    backend_destroy()
}

app_clear :: proc(self: ^App)
{
    slot_table_clear(&self.table)
    layer_stack_clear(&self.stack)
}

app_create_layer :: proc(self: ^App, value: Layer) -> int
{
    return slot_table_insert(&self.table, value)
}

app_delete_layer :: proc(self: ^App, ident: int) -> (Layer, bool)
{
    return slot_table_remove(&self.table, ident)
}

app_find_layer :: proc(self: ^App, ident: int) -> Handle(Layer)
{
    return slot_table_find(&self.table, ident)
}

app_stack_clear :: proc(self: ^App)
{
    it := layer_stack_iter(&self.stack)

    for layer in layer_stack_next_below(&it) {
        layer_leave(layer)
    }

    layer_stack_clear(&self.stack)
}

app_stack_push :: proc(self: ^App, ident: int) -> bool
{
    handle := app_find_layer(self, ident)

    if handle.ident != 0 {
        ident := layer_stack_insert(&self.stack, handle.value^)
        layer := layer_stack_find(&self.stack, ident)

        if layer.ident != 0 {
            layer_enter(layer.value)
        }

        return layer.ident != 0
    }

    return false
}

app_stack_pop :: proc(self: ^App)
{
    value, state := layer_stack_remove(&self.stack)

    if state == true {
        layer_leave(&value)
    }
}

app_stack_set :: proc(self: ^App, ident: int) -> bool
{
    app_stack_clear(self)

    return app_stack_push(self, ident)
}

app_start :: proc(self: ^App)
{
    it := slot_table_iter(&self.table)

    for layer in slot_table_next(&it) {
        layer_start(layer, self)
    }
}

app_stop :: proc(self: ^App)
{
    it := slot_table_iter(&self.table)

    for layer in slot_table_next(&it) {
        layer_stop(layer)
    }
}

app_loop :: proc(self: ^App, config: App_Config) -> bool
{
    tick := time.Tick {}

    frame_rate := f64 {}
    frame_time := f64 {}
    total_time := f64 {}
    delta_time := f64 {}

    frame_rate = max(1.0, f64(config.max_frame_rate))
    delta_time = 1.0 / frame_rate

    app_start(self)
    app_stack_set(self, config.first_layer)

    for skips := 0; layer_stack_len(&self.stack) > 0; skips = 0 {
        frame_time  = time.duration_seconds(time.tick_lap_time(&tick))
        total_time += frame_time

        app_paint(self)
        app_frame(self, f32(frame_time))

        for delta_time < total_time && skips <= config.max_frame_skip {
            app_step(self, f32(delta_time))

            total_time -= delta_time
            skips      += 1
        }

        app_event(self)
    }

    app_stack_clear(self)
    app_stop(self)

    return true
}

app_event :: proc(self: ^App)
{
    event := poll_event()

    input_reset(&self.input)

    for ; event != nil; event = poll_event() {
        input_event(&self.input, event)

        it := layer_stack_iter(&self.stack)

        for layer in layer_stack_next_below(&it) {
            if layer_event(layer, event) == false { break }
        }
    }
}

app_frame :: proc(self: ^App, delta_time: f32)
{
    it := layer_stack_iter(&self.stack)

    for layer in layer_stack_next_below(&it) {
        layer_frame(layer, delta_time)
    }
}

app_step :: proc(self: ^App, delta_time: f32)
{
    it := layer_stack_iter(&self.stack)

    for layer in layer_stack_next_below(&it) {
        layer_step(layer, delta_time)
    }
}

app_paint :: proc(self: ^App)
{
    painter_begin_batch(&self.painter)

    it := layer_stack_iter(&self.stack)

    for layer in layer_stack_next_above(&it) {
        layer_paint(layer)
    }

    painter_end_batch(&self.painter)
    window_swap_buffers(nil)
}
