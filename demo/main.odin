package demo

import       "core:fmt"
import       "core:log"
import mathl "core:math/linalg"

import "../pax"

WINDOW_DIMENSION := [2]f32 {320, 180}
WINDOW_SCALE     := [2]f32 {1, 1}

Demo_Layer :: struct
{
    app: ^pax.App,

    shader: pax.Shader,
    view:   pax.View,

    delta: [2]f32,
    speed: f32,
}

demo_layer_start :: proc(self: ^Demo_Layer, app: ^pax.App) -> bool
{
    builder   := pax.Shader_Builder {}
    dimension := WINDOW_DIMENSION * WINDOW_SCALE

    self.app = app

    pax.view_set_viewport(&self.view, {0, 0, dimension.x, dimension.y})
    pax.view_set_origin(&self.view, {dimension.x / 2, dimension.y / 2})

    pax.shader_vertex(&builder, #load("../data/vertex.glsl"))
    pax.shader_fragment(&builder, #load("../data/fragment.glsl"))

    self.shader = pax.shader_init(&builder) or_return

    pax.window_set_dimension(nil, {
        int(dimension.x), int(dimension.y),
    })

    self.speed = 100

    pax.window_show()

    return true
}

demo_layer_stop :: proc(self: ^Demo_Layer)
{
    pax.window_hide()
}

demo_layer_event :: proc(self: ^Demo_Layer, event: pax.Event) -> bool
{
    #partial switch type in event {
        case pax.App_Close_Event:     pax.app_stack_pop(self.app)
        case pax.Window_Resize_Event: pax.view_set_viewport(&self.view, {0, 0, f32(type.dimension.x), f32(type.dimension.y)})
    }

    if pax.input_test_keyboard_key(&self.app.input, 0, .KEY_ESCAPE) {
        pax.app_stack_pop(self.app)
    }

    delta := [2]f32 {}

    if pax.input_test_keyboard_key(&self.app.input, 0, .KEY_W) { delta.y -= 1 }
    if pax.input_test_keyboard_key(&self.app.input, 0, .KEY_A) { delta.x -= 1 }
    if pax.input_test_keyboard_key(&self.app.input, 0, .KEY_S) { delta.y += 1 }
    if pax.input_test_keyboard_key(&self.app.input, 0, .KEY_D) { delta.x += 1 }

    self.delta = mathl.normalize0(delta)

    return false
}

demo_layer_step :: proc(self: ^Demo_Layer, delta_time: f32)
{
    view_pos := self.view.position + self.delta * self.speed * delta_time

    pax.view_set_position(&self.view, view_pos)
}

demo_layer_paint :: proc(self: ^Demo_Layer)
{
    pax.painter_set_view(&self.app.painter, &self.view)
    pax.painter_set_shader(&self.app.painter, &self.shader)

    pax.painter_set_mat4_f32(&self.app.painter, "unif_view", pax.view_get_matrix(&self.view))

    pax.painter_batch_poly4(&self.app.painter, {
        pax.paint_vertex_init({  0,   0}, pax.color_from_u32le(0xff0000ff)),
        pax.paint_vertex_init({  0, 100}, pax.color_from_u32le(0xffff00ff)),
        pax.paint_vertex_init({100, 100}, pax.color_from_u32le(0x00ffffff)),
        pax.paint_vertex_init({100,   0}, pax.color_from_u32le(0x0000ffff)),
    })

    pax.painter_clear_color(&self.app.painter, {0, 0, 0, 1})
}

demo_layer :: proc(self: ^Demo_Layer) -> pax.Layer
{
    value := pax.LAYER

    value.self = auto_cast self

    value.proc_start = auto_cast demo_layer_start
    value.proc_stop  = auto_cast demo_layer_stop
    value.proc_event = auto_cast demo_layer_event
    value.proc_step  = auto_cast demo_layer_step
    value.proc_paint = auto_cast demo_layer_paint

    value.proc_enter = auto_cast proc(self: ^Demo_Layer)
    {
        fmt.printf("Enter demo\n")
    }

    value.proc_leave = auto_cast proc(self: ^Demo_Layer)
    {
        fmt.printf("Leave demo\n")
    }

    return value
}

main :: proc()
{
    context.logger = log.create_console_logger()

    app  := pax.App {}
    demo := Demo_Layer {}

    if pax.app_init(&app) {
        demo_ident := pax.app_create_layer(&app, demo_layer(&demo))

        pax.app_loop(&app, {
            first_layer    = demo_ident,
            max_frame_rate = 60,
            max_frame_skip = 60,
        })

        pax.app_destroy(&app)
    }
}
