package demo

import "core:fmt"
import "core:log"

import "../pax"

Demo :: struct
{
    using app: pax.App,

    shader: pax.Shader,
    view:   pax.View,
}

Demo_Layer :: struct
{
    demo: ^Demo,
}

demo_layer_start :: proc(self: ^Demo_Layer, demo: ^Demo) -> bool
{
    self.demo = demo

    pax.render_set_shader(&self.demo.render, &self.demo.shader)
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
        case pax.App_Close_Event: pax.app_stack_pop(self.demo)
    }

    if pax.input_test_keyboard_key(&self.demo.input, 0, .KEY_ESCAPE) {
        pax.app_stack_pop(self.demo)
    }

    return false
}

demo_layer_draw :: proc(self: ^Demo_Layer)
{
    pax.shader_bind(&self.demo.shader)

    pax.render_clear_color(&self.demo.render, {0, 0, 0, 1})
    pax.render_set_m4f32(&self.demo.render, "unif_proj", self.demo.render.ortho)
    // pax.render_set_m4f32(&self.demo.render, "unif_view", self.demo.view)

    pax.render_begin_batch(&self.demo.render)

    pax.render_draw_triangle(&self.demo.render, {
        { position = {   0,  0.5}, color = {1.0, 0.0, 0.0, 1.0} },
        { position = {-0.5, -0.5}, color = {0.0, 1.0, 0.0, 1.0} },
        { position = { 0.5, -0.5}, color = {0.0, 0.0, 1.0, 1.0} },
    })

    pax.render_draw_triangle(&self.demo.render, {
        { position = {-0.75,  0.5}, color = {1.0, 0.0, 0.0, 1.0} },
        { position = {-0.75, -0.5}, color = {0.0, 1.0, 0.0, 1.0} },
        { position = {-0.70,    0}, color = {0.0, 0.0, 1.0, 1.0} },
    })

    pax.render_end_batch(&self.demo.render)
}

demo_layer :: proc(self: ^Demo_Layer) -> pax.Layer
{
    value := pax.LAYER

    value.self = auto_cast self

    value.proc_start = auto_cast demo_layer_start
    value.proc_stop  = auto_cast demo_layer_stop
    value.proc_event = auto_cast demo_layer_event
    value.proc_draw  = auto_cast demo_layer_draw

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

    builder := pax.Shader_Builder {}

    demo   := Demo {}
    demo_l := Demo_Layer {}

    if pax.app_init(&demo) {
        pax.shader_vertex(&builder, #load("../data/vertex.glsl"))
        pax.shader_fragment(&builder, #load("../data/fragment.glsl"))

        demo.shader, _ = pax.shader_init(&builder)

        demo_h := pax.app_create_layer(&demo, demo_layer(&demo_l))

        pax.app_loop(&demo, {
            first_layer    = demo_h,
            max_frame_rate = 60,
            max_frame_skip = 60,
        })

        pax.app_destroy(&demo)
    }
}
