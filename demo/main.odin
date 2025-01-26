package demo

import "core:fmt"
import "core:log"

import "../pax"

Demo :: struct
{
    using app: pax.App,

    window: pax.Window_Handle,
}

Demo_Layer :: struct
{
    demo: ^Demo,
}

demo_layer_start :: proc(self: ^Demo_Layer, demo: ^Demo) -> bool
{
    self.demo = demo

    return true
}

demo_layer_event :: proc(self: ^Demo_Layer, event: pax.Event) -> bool
{
    #partial switch type in event {
        case pax.App_Close_Event: pax.app_stack_pop(self.demo)
    }

    if pax.app_test_keyboard_key(self.demo, 0, .KEY_ESCAPE) {
        pax.app_stack_push(self.demo, 1)
    }

    return false
}

demo_layer :: proc(self: ^Demo_Layer) -> pax.Layer
{
    value := pax.LAYER

    value.self = auto_cast self

    value.proc_start = auto_cast demo_layer_start
    value.proc_event = auto_cast demo_layer_event

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

    pax.app_init(&demo)

    demo.window = pax.window_init({320, 180}, "Pax")

    demo_h := pax.app_create_layer(&demo, demo_layer(&demo_l))

    pax.app_loop(&demo, {
        first_layer    = demo_h,
        max_frame_rate = 60,
        max_frame_skip = 60,
    })

    pax.window_destroy(&demo.window)
    pax.app_destroy(&demo)
}
