package pax

import "core:log"
import "core:time"

//
// Definitions
//

App :: struct
{
    input:  Input_State,
    stack:  Layer_Stack,
    render: Render_State,
    shader: Shader,

    table: Slot_Table(Layer),
}

App_Config :: struct
{
    first_layer:    Handle(Layer),
    max_frame_rate: int,
    max_frame_skip: int,
}

//
// Functions
//

app_init :: proc(self: ^App, allocator := context.allocator) -> bool
{
    builder := Shader_Builder {}

    backend_init({320, 180}, "Pax") or_return

    shader_vertex(&builder, #load("../data/vertex.glsl")) or_return
    shader_fragment(&builder, #load("../data/fragment.glsl")) or_return

    self.table  = slot_table_init(Layer, allocator)
    self.stack  = layer_stack_init(allocator)

    self.render = render_init()
    self.shader = shader_init(&builder) or_return

    render_set_shader(&self.render, &self.shader)
    render_set_viewport(&self.render, {0, 0, 320, 180})

    return true
}

app_destroy :: proc(self: ^App)
{
    shader_destroy(&self.shader)
    render_destroy(&self.render)

    layer_stack_destroy(&self.stack)
    slot_table_destroy(&self.table)

    backend_destroy()
}

app_clear :: proc(self: ^App)
{
    slot_table_clear(&self.table)
    layer_stack_clear(&self.stack)
}

app_create_layer :: proc(self: ^App, value: Layer) -> Handle(Layer)
{
    return slot_table_insert(&self.table, value)
}

app_delete_layer :: proc(self: ^App, slot: int) -> (Layer, bool)
{
    return slot_table_remove(&self.table, slot)
}

app_find_layer :: proc(self: ^App, slot: int) -> Handle(Layer)
{
    return slot_table_find(&self.table, slot)
}

app_stack_clear :: proc(self: ^App)
{
    it := layer_stack_iter(&self.stack)

    for layer in layer_stack_next(&it) {
        layer_leave(layer)
    }

    layer_stack_clear(&self.stack)
}

app_stack_push :: proc(self: ^App, slot: int) -> bool
{
    handle := app_find_layer(self, slot)

    if handle.slot == 0 { return false }

    handle = layer_stack_insert(&self.stack, handle.value^)

    if handle.slot == 0 { return false }

    layer_enter(handle.value)

    return true
}

app_stack_pop :: proc(self: ^App)
{
    value, state := layer_stack_remove(&self.stack)

    if state == true {
        layer_leave(&value)
    }
}

app_stack_set :: proc(self: ^App, slot: int) -> bool
{
    app_stack_clear(self)

    return app_stack_push(self, slot)
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

    frame_rate: f64 = max(1.0, f64(config.max_frame_rate))
    frame_time: f64 = 0
    delta_time: f64 = 1.0 / frame_rate
    total_time: f64 = 0

    app_start(self)
    app_stack_set(self, config.first_layer.slot)

    for skips := 0; layer_stack_size(&self.stack) > 0; skips = 0 {
        frame_time  = time.duration_seconds(time.tick_lap_time(&tick))
        total_time += frame_time

        app_draw(self)
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

        for layer in layer_stack_next_reverse(&it) {
            if layer_event(layer, event) == false { break }
        }
    }
}

app_frame :: proc(self: ^App, delta_time: f32)
{
    it := layer_stack_iter(&self.stack)

    for layer in layer_stack_next_reverse(&it) {
        layer_frame(layer, delta_time)
    }
}

app_step :: proc(self: ^App, delta_time: f32)
{
    it := layer_stack_iter(&self.stack)

    for layer in layer_stack_next_reverse(&it) {
        layer_step(layer, delta_time)
    }
}

app_draw :: proc(self: ^App)
{
    render_clear_color(&self.render, {})
    render_begin_batch(&self.render)

    it := layer_stack_iter(&self.stack)

    for layer in layer_stack_next(&it) {
        layer_draw(layer)
    }

    render_end_batch(&self.render)

    window_swap_buffers(nil)
}
