package demo

import       "core:fmt"
import       "core:log"
import       "core:strings"
import mathl "core:math/linalg"

import "../pax"

WINDOW_RESOLUTION := [2]f32 {320, 180}
WINDOW_SCALE      := [2]f32 {3, 3}

WINDOW_DIMENSION := WINDOW_RESOLUTION * WINDOW_SCALE

Demo_Layer :: struct
{
    shader:  pax.Shader,
    texture: pax.Texture,
    view:    pax.View,

    ctrls: [4]b8,

    angle: [2]f32,
    speed: f32,
}

demo_layer_start :: proc(self: ^Demo_Layer, app: ^pax.App) -> bool
{
    shader  := pax.Shader_Builder {}
    texture := pax.Texture_Builder {}
    dim     := WINDOW_DIMENSION
    res     := WINDOW_RESOLUTION

    pax.shader_set_vertex(&shader, #load("../data/vertex.glsl"))
    pax.shader_set_fragment(&shader, #load("../data/fragment.glsl"))

    self.shader  = pax.shader_init(&shader) or_return
    self.texture = pax.texture_read(&texture, "data/atlas.png") or_return
    self.speed   = 300

    pax.view_set_viewport(&self.view, {0, 0, dim.x, dim.y})
    pax.view_set_dimension(&self.view, res)
    pax.view_set_bounds(&self.view, {-res.x / 2, -res.y / 2, res.x * 2, res.y * 2})
    pax.view_set_scale(&self.view, WINDOW_SCALE)

    pax.window_show(app.window)

    return true
}

demo_layer_stop :: proc(self: ^Demo_Layer, app: ^pax.App)
{
    pax.window_hide(app.window)
}

demo_layer_event :: proc(self: ^Demo_Layer, app: ^pax.App, event: pax.Event) -> bool
{
    #partial switch type in event {
        case pax.App_Close_Event: pax.app_stack_pop(app)

        case pax.Window_Resize_Event: {
            dim := [2]f32 {f32(type.dimension.x), f32(type.dimension.y)}

            WINDOW_SCALE     = dim / WINDOW_RESOLUTION
            WINDOW_DIMENSION = dim

            pax.view_set_viewport(&self.view, {0, 0, dim.x, dim.y})
            pax.view_set_scale(&self.view, WINDOW_SCALE)
        }
    }

    if pax.input_test_keyboard_key(&app.input, 0, .KEY_ESCAPE) {
        pax.app_stack_pop(app)
    }

    return false
}

demo_layer_frame :: proc(self: ^Demo_Layer, app: ^pax.App, frame_time: f32)
{
    builder := strings.builder_make()

    fmt.sbprintf(&builder, "%.6f", frame_time)

    pax.window_set_title(app.window, strings.to_string(builder))
}

demo_layer_tick :: proc(self: ^Demo_Layer, app: ^pax.App, delta_time: f32)
{
    self.ctrls[0] = b8(pax.input_test_keyboard_btn(&app.input, 0, .BTN_W))
    self.ctrls[1] = b8(pax.input_test_keyboard_btn(&app.input, 0, .BTN_A))
    self.ctrls[2] = b8(pax.input_test_keyboard_btn(&app.input, 0, .BTN_S))
    self.ctrls[3] = b8(pax.input_test_keyboard_btn(&app.input, 0, .BTN_D))

    angle := [2]f32 {
        f32(int(self.ctrls[3]) - int(self.ctrls[1])),
        f32(int(self.ctrls[2]) - int(self.ctrls[0])),
    }

    self.angle = mathl.normalize0(angle)

    pax.view_move_by(&self.view, self.angle * self.speed * delta_time)
}

demo_layer_paint :: proc(self: ^Demo_Layer, app: ^pax.App)
{
    pax.painter_set_view(&app.painter, &self.view)
    pax.painter_set_shader(&app.painter, &self.shader)

    pax.painter_set_mat4_f32(&app.painter, "unif_view", pax.view_get_matrix(&self.view))

    pax.painter_batch_poly4(&app.painter, {
        pax.paint_vertex_init({ 0,  0}, pax.color_from_u32le(0xffffffff), {0, 0}),
        pax.paint_vertex_init({ 0, 80}, pax.color_from_u32le(0xffffffff), {0, 1}),
        pax.paint_vertex_init({40, 80}, pax.color_from_u32le(0xffffffff), {1, 1}),
        pax.paint_vertex_init({40,  0}, pax.color_from_u32le(0xffffffff), {1, 0}),
    }, &self.texture)

    pax.painter_clear_color(&app.painter, {0, 0, 0, 1})
}

demo_layer :: proc(self: ^Demo_Layer) -> pax.Layer
{
    value := pax.LAYER

    value.self = auto_cast self

    value.proc_start = auto_cast demo_layer_start
    value.proc_stop  = auto_cast demo_layer_stop
    value.proc_event = auto_cast demo_layer_event
    value.proc_frame = auto_cast demo_layer_frame
    value.proc_tick  = auto_cast demo_layer_tick
    value.proc_paint = auto_cast demo_layer_paint

    value.proc_enter = auto_cast proc(self: ^Demo_Layer, app: ^pax.App)
    {
        fmt.printf("Enter demo\n")
    }

    value.proc_leave = auto_cast proc(self: ^Demo_Layer, app: ^pax.App)
    {
        fmt.printf("Leave demo\n")
    }

    return value
}

main :: proc()
{
    context.logger = log.create_console_logger()

    app := pax.App {}

    demo := Demo_Layer {}
    dim  := WINDOW_DIMENSION

    if pax.app_init(&app, {int(dim.x), int(dim.y)}) == false {
        return
    }

    demo_ident := pax.app_create_layer(&app, demo_layer(&demo))

    pax.app_loop(&app, {
        first_layer    = demo_ident,
        max_frame_rate = 64,
        max_frame_skip = 64,
    })

    pax.app_destroy(&app)
}
