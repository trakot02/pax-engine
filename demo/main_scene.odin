package demo

import       "core:fmt"
import math  "core:math"
import mathl "core:math/linalg"

import "../pax"

WINDOW_RESOLUTION := [2]f32 {320, 180}
WINDOW_SCALE      := [2]f32 {4, 4}

WINDOW_DIMENSION := WINDOW_RESOLUTION * WINDOW_SCALE

Main_Scene :: struct
{
    shader:  pax.Shader,
    texture: pax.Texture,
    view:    pax.View,

    anim:  pax.Animation,
    batch: pax.Sprite_Batch,

    speed: f32,
    time:  f32,
}

main_scene_start :: proc(self: ^Main_Scene, app: ^pax.App) -> bool
{
    dim := WINDOW_DIMENSION
    res := WINDOW_RESOLUTION

    self.shader  = pax.sprite_shader() or_return
    self.texture = pax.texture_read("data/atlas.png") or_return
    self.speed   = 200

    self.anim       = pax.animation_init({0, 0}, {48, 48}, {16, 48})
    self.anim.delay = 0.2

    pax.view_set_viewport(&self.view, {0, 0, dim.x, dim.y})
    pax.view_set_position(&self.view, {0, 0})
    pax.view_set_dimension(&self.view, res)
    pax.view_set_bounds(&self.view, {-res.x / 2, -res.y / 2, res.x * 2, res.y * 2})
    pax.view_set_scale(&self.view, WINDOW_SCALE)

    rect := pax.window_get_rect(app.window)

    rect.xy += rect.zw / 2

    rect.z = int(dim.x)
    rect.w = int(dim.y)

    rect.xy -= rect.zw / 2

    pax.window_set_rect(app.window, rect)
    pax.window_set_visible(app.window, true)

    return true
}

main_scene_stop :: proc(self: ^Main_Scene, app: ^pax.App)
{
    pax.window_set_visible(app.window, false)
}

main_scene_event :: proc(self: ^Main_Scene, app: ^pax.App, event: pax.Event) -> bool
{
    #partial switch value in event {
        case pax.App_Close_Event: pax.app_stack_pop(app)

        case pax.Window_Resize_Event: {
            dim := [2]f32 {f32(value.dimension.x), f32(value.dimension.y)}

            WINDOW_SCALE     = dim / WINDOW_RESOLUTION
            WINDOW_DIMENSION = dim

            pax.view_set_viewport(&self.view, {0, 0, dim.x, dim.y})
            pax.view_set_scale(&self.view, WINDOW_SCALE)
        }
    }

    if pax.input_test_keyboard_key(&app.input, 0, .KEY_ESCAPE) {
        pax.app_stack_pop(app)
    }
    
    wheel := pax.input_get_mouse_wheel(&app.input, 0).y

    pax.animation_add_delay(&self.anim, wheel / 1000.0)

    return false
}

main_scene_tick :: proc(self: ^Main_Scene, app: ^pax.App, delta_time: f32)
{ 
    ctrls := [4]int {
        int(pax.input_test_keyboard_key(&app.input, 0, .KEY_D)),
        int(pax.input_test_keyboard_key(&app.input, 0, .KEY_S)),
        int(pax.input_test_keyboard_key(&app.input, 0, .KEY_A)),
        int(pax.input_test_keyboard_key(&app.input, 0, .KEY_W)),
    }

    angle := mathl.normalize0([2]f32 {
        f32(ctrls[0] - ctrls[2]),
        f32(ctrls[1] - ctrls[3]),
    })

    pax.view_move_by(&self.view, angle * self.speed, delta_time)

    pax.animation_tick(&self.anim, delta_time)
}

main_scene_begin_frame :: proc(self: ^Main_Scene, app: ^pax.App, frame_time: f32)
{
    self.time += frame_time
}

main_scene_end_frame :: proc(self: ^Main_Scene, app: ^pax.App, frame_time: f32)
{
    res := WINDOW_RESOLUTION

    pax.sprite_batch_set_shader(&self.batch, &self.shader)
    pax.sprite_batch_set_view(&self.batch, &self.view)
    pax.sprite_batch_set_texture(&self.batch, &self.texture)

    frame := pax.animation_get_frame(&self.anim)

    pax.sprite_batch_push(&self.batch, {
        frame     = frame,
        dimension = {16, 48},
        color     = {1, 1, 1, 1},
    }, {
        position = {16, 16},
        scale    = {2, 2},
        pivot    = {0.5, 0.5},
        rotation = self.time,
    })

    pax.sprite_batch_flush(&self.batch, &app.render)
}

main_scene :: proc(self: ^Main_Scene) -> pax.Scene
{
    value := pax.SCENE

    value.self = auto_cast self

    value.proc_start       = auto_cast main_scene_start
    value.proc_stop        = auto_cast main_scene_stop
    value.proc_event       = auto_cast main_scene_event
    value.proc_tick        = auto_cast main_scene_tick
    value.proc_begin_frame = auto_cast main_scene_begin_frame
    value.proc_end_frame   = auto_cast main_scene_end_frame

    return value
}
