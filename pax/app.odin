package pax

import "core:log"
import "core:time"

//
// Definitions
//

// TODO(gio): Split internal state and accessible state.
App :: struct
{
    window:  ^Window,
    render:  Render_State,
    input:   Input_State,

    table: Slot_Table(Scene_Layer),
    stack: Scene_Stack,
}

App_Config :: struct
{
    first_scene:    int,
    max_frame_rate: int,
    max_frame_skip: int,
}

//
// Functions
//

app_init :: proc(self: ^App, allocator := context.allocator) -> bool
{
    backend_init({320, 180}, "Pax") or_return

    self.render = render_init() or_return
    self.window = window_main()

    self.table = slot_table_init(Scene_Layer, allocator)
    self.stack = scene_stack_init(allocator)

    return true
}

app_destroy :: proc(self: ^App)
{
    scene_stack_destroy(&self.stack)
    slot_table_destroy(&self.table)

    render_destroy(&self.render)

    backend_destroy()
}

app_clear :: proc(self: ^App)
{
    slot_table_clear(&self.table)
    scene_stack_clear(&self.stack)
}

app_insert_scene :: proc(self: ^App, value: Scene_Layer) -> int
{
    return slot_table_insert(&self.table, value)
}

app_remove_scene :: proc(self: ^App, ident: int) -> (Scene_Layer, bool)
{
    return slot_table_remove(&self.table, ident)
}

app_find_scene :: proc(self: ^App, ident: int) -> ^Scene_Layer
{
    return slot_table_find(&self.table, ident)
}

app_clear_stack :: proc(self: ^App)
{
    iter := scene_stack_iter(&self.stack)

    for scene in scene_stack_next_below(&iter) {
        scene_layer_leave(scene, self)
    }

    scene_stack_clear(&self.stack)
}

app_push_scene :: proc(self: ^App, ident: int) -> bool
{
    value := app_find_scene(self, ident)

    if value != nil {
        ident := scene_stack_insert(&self.stack, value^)
        value  = scene_stack_find(&self.stack, ident)

        if value != nil {
            scene_layer_enter(value, self)
        }

        return value != nil
    }

    return false
}

app_pop_scene :: proc(self: ^App)
{
    value, state := scene_stack_remove(&self.stack)

    if state == true {
        scene_layer_leave(&value, self)
    }
}

app_set_scene :: proc(self: ^App, ident: int) -> bool
{
    app_clear_stack(self)

    return app_push_scene(self, ident)
}

app_start :: proc(self: ^App) -> bool
{
    iter := slot_table_iter(&self.table)
    last := 0
    succ := true

    for scene, ident in slot_table_next(&iter) {
        last = ident
        succ = scene_layer_start(scene, self)

        if succ == false { break }
    }

    if succ == false {
        iter = slot_table_iter(&self.table)

        for scene, ident in slot_table_next(&iter) {
            if last == ident { break }

            scene_layer_stop(scene, self)
        }
    }

    return succ
}

app_stop :: proc(self: ^App)
{
    iter := slot_table_iter(&self.table)

    for scene in slot_table_next(&iter) {
        scene_layer_stop(scene, self)
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

    if app_start(self) == false { return false }

    app_set_scene(self, config.first_scene)

    for skips := 0; scene_stack_len(&self.stack) > 0; skips = 0 {
        frame_time  = time.duration_seconds(time.tick_lap_time(&tick))
        total_time += frame_time

        render_clear(&self.render)

        app_event(self)
        app_begin_frame(self, f32(frame_time))

        for delta_time < total_time && skips <= config.max_frame_skip {
            app_tick(self, f32(delta_time))

            total_time -= delta_time
            skips      += 1
        }

        app_end_frame(self, f32(frame_time))

        render_flush(&self.render)
        window_swap_buffers(self.window)
    }

    app_clear_stack(self)
    app_stop(self)

    return true
}

app_event :: proc(self: ^App)
{
    event := poll_event()
    iter  := scene_stack_iter(&self.stack)

    for ; event != nil; event = poll_event() {
        input_event(&self.input, event)

        for scene in scene_stack_next_below(&iter) {
            state := scene_layer_event(scene, self, event)

            if state == false {
                break
            }
        }
    }

    input_reset(&self.input)
}

app_tick :: proc(self: ^App, delta_time: f32)
{
    iter := scene_stack_iter(&self.stack)

    for scene in scene_stack_next_below(&iter) {
        scene_layer_tick(scene, self, delta_time)
    }
}

app_begin_frame :: proc(self: ^App, frame_time: f32)
{
    iter := scene_stack_iter(&self.stack)

    for scene in scene_stack_next_below(&iter) {
        scene_layer_begin_frame(scene, self, frame_time)
    }
}

app_end_frame :: proc(self: ^App, frame_time: f32)
{
    iter := scene_stack_iter(&self.stack)

    for scene in scene_stack_next_above(&iter) {
        scene_layer_end_frame(scene, self, frame_time)
    }
}
