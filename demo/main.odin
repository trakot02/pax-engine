package demo

import "core:log"

import rl  "vendor:raylib"
import pax "../pax"
import gui "../pax/gui"
import res "../pax/res"

Game_Stage :: struct {}

game_stage_start :: proc(self: ^Game_Stage) -> bool
{
    rl.SetWindowState({.WINDOW_RESIZABLE, .WINDOW_HIDDEN})
    rl.InitWindow(1280, 720, "GUI")

    return true
}

game_stage_stop  :: proc(self: ^Game_Stage)
{
    rl.CloseWindow()
}

game_stage :: proc(self: ^Game_Stage) -> pax.Stage
{
    value := pax.STAGE

    value.self       = auto_cast self
    value.proc_start = auto_cast game_stage_start
    value.proc_stop  = auto_cast game_stage_stop

    return value
}

Demo_Scene :: struct
{
    gui: gui.State,

    textures: res.Holder(res.Texture),

    atlas: int,
    state: int,

    value:  f32,
    colors: [3][4]u8,
    color:  int,
}

demo_scene_start :: proc(self: ^Demo_Scene, stage: ^Game_Stage) -> bool
{
    res.holder_init(&self.textures)

    gui.init(&self.gui, &self.textures)

    self.atlas, _ = res.texture_read_and_insert(&self.textures, "data/atlas.png")

    self.colors = {
        {224,  96,  96, 255},
        { 96, 224,  96, 255},
        { 96,  96, 224, 255},
    }

    rl.ClearWindowState({.WINDOW_HIDDEN})

    return true
}

demo_scene_stop :: proc(self: ^Demo_Scene)
{
    // empty.
}

demo_scene_frame :: proc(self: ^Demo_Scene)
{
    gui.flush(&self.gui)
    gui.update(&self.gui, rl.GetMouseDelta())

    window_rect := [4]f32 {
        0, 0,
        f32(rl.GetScreenWidth()),
        f32(rl.GetScreenHeight()),
    }

    root, _ := gui.insert_root(&self.gui, {
        offset = window_rect,
        fill   = {32, 32, 32, 255},
    })

    list, _ := gui.insert_child(&self.gui, root, {
        origin = {0.5, 0.5},
        factor = {0.5, 0.5, 0.34, 0.75},
        group  = gui.List_Group {
            direction = .ROW,
            between   = 8,
        }
    })

    button, _ := gui.insert_child(&self.gui, list, {
        offset = {0, 0, 256, 48},
        origin = {0.5, 0.5},
        factor = {0.5, 0.5, 1, 0},
        fill   = self.colors[self.color],
    })

    slider, _ := gui.insert_child(&self.gui, list, {
        origin = {0.5, 0.5},
        factor = {0.5, 0.5, 0, 0},
        fill   = [4]u8 {255, 255, 255, 255 - u8(self.value)},
        group  = gui.Image_Group {
            slot  = self.atlas,
            scale = {3, 3},
        },
    })

    gui.layout(&self.gui)

    button_info := gui.Button_Info {
        pressed  = b8(rl.IsMouseButtonPressed(.LEFT)),
        released = b8(rl.IsMouseButtonReleased(.LEFT)),
    }

    slider_info := gui.Slider_Info {
        pressed  = b8(rl.IsMouseButtonPressed(.LEFT)),
        released = b8(rl.IsMouseButtonReleased(.LEFT)),
        movement = self.gui.delta.x,
        range    = {0, 255},
        step     = 1,
    }

    gui.button(&self.gui, list, button_info)

    if gui.button(&self.gui, button, button_info) {
        self.color += 1
        self.color %= len(self.colors)
    }

    gui.slider(&self.gui, slider, slider_info, &self.value)
}

demo_scene_input :: proc(self: ^Demo_Scene) -> int
{
    if rl.WindowShouldClose() { self.state = -1 }

    return self.state
}

demo_scene_step  :: proc(self: ^Demo_Scene, delta: f32)
{
    // empty.
}

demo_scene_draw  :: proc(self: ^Demo_Scene)
{
    rl.ClearBackground({255, 255, 255, 255})
    rl.BeginDrawing()

    for slot in 1 ..= len(self.gui.nodes) {
        handle := gui.find(&self.gui, slot)

        rect := rl.Rectangle {
            handle.bounds.x, handle.bounds.y,
            handle.bounds.z, handle.bounds.w,
        }

        fill := rl.Color {
            handle.fill.r, handle.fill.g,
            handle.fill.b, handle.fill.a,
        }

        #partial switch group in handle.group {
            case gui.Image_Group: {
                texture := res.holder_find(&self.textures, group.slot)

                if texture.slot == 0 { continue }

                src := rl.Rectangle {0, 0,
                    f32(texture.value.width),
                    f32(texture.value.height),
                }

                rl.DrawTexturePro(texture.value^, src, rect, {}, 0, fill)
            }

            case nil: rl.DrawRectangleRec(rect, fill)
        }

        if gui.is_active(&self.gui, handle) {
            rl.DrawRectangleLinesEx(rect, 2, {255, 255, 255, 255})
        }

        if gui.is_target(&self.gui, handle) {
            rl.DrawRectangleRec(rect, {255, 255, 255, 32})
        }
    }

    rl.EndDrawing()
}

demo_scene :: proc(self: ^Demo_Scene) -> pax.Scene
{
    value := pax.SCENE

    value.self       = auto_cast self
    value.proc_start = auto_cast demo_scene_start
    value.proc_stop  = auto_cast demo_scene_stop
    value.proc_frame = auto_cast demo_scene_frame
    value.proc_input = auto_cast demo_scene_input
    value.proc_step  = auto_cast demo_scene_step
    value.proc_draw  = auto_cast demo_scene_draw

    return value
}

main :: proc()
{
    context.logger = log.create_console_logger(lowest = .Debug)

    game := Game_Stage {}
    demo := Demo_Scene {}

    stage := game_stage(&game)

    pax.stage_init(&stage)
    pax.stage_create(&stage, demo_scene(&demo))

    pax.stage_loop(&stage, {
        max_frame_rate = 60,
        max_frame_skip = 1,
        first_scene    = 1,
    })

    pax.stage_destroy(&stage)
}
