package demo

import "core:fmt"
import "core:log"

import "../pax"

Demo :: struct
{
    using app: pax.App,
}

Demo_Layer :: struct
{
    demo: ^Demo,
}

demo_layer_start :: proc(self: ^Demo_Layer, demo: ^Demo) -> bool
{
    self.demo = demo

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
        case pax.App_Close_Event:     pax.app_stack_push(self.demo, 1)
        case pax.Window_Resize_Event: pax.render_set_viewport(&self.demo.render, {0, 0, f32(type.size.x), f32(type.size.y)})
    }

    if pax.input_test_keyboard_key(&self.demo.input, 0, .KEY_ESCAPE) {
        pax.app_stack_pop(self.demo)
    }

    return false
}

demo_layer_draw :: proc(self: ^Demo_Layer)
{
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

    demo   := Demo {}
    demo_l := Demo_Layer {}

    if pax.app_init(&demo) {
        demo_h := pax.app_create_layer(&demo, demo_layer(&demo_l))

        pax.app_loop(&demo, {
            first_layer    = demo_h,
            max_frame_rate = 60,
            max_frame_skip = 60,
        })

        pax.app_destroy(&demo)
    }
}
