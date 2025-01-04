package demo

import "core:log"

import rl "vendor:raylib"

import "../pax"

Menu_Scene :: struct
{
    gui: pax.GUI_Layer,

    state: int,
}

menu_scene_gui :: proc(self: ^Menu_Scene)
{
    pax.gui_append_root(&self.gui, {
        shape = { color = {32, 32, 32, 255} }
    })

    pax.gui_append_child(&self.gui, 1, {
        shape = {
            offset   = {0, 0, 512, 0},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0.75},
        },
        group = pax.GUI_Flex_Group {
            direction = .COL,
            placement = .ALIGN_CENTER,
            between   = 16,
            stretch   = true,
        }
    })

    pax.gui_append_child(&self.gui, 2, {
        shape = {
            offset   = {0, 0, 0, 60},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {64, 192, 64, 255},
        },
        input = pax.gui_input_from(self, proc(layer: ^pax.GUI_Layer, number: int, scene: ^Menu_Scene) {
            pax.gui_focused(layer, number, rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonPressed(.RIGHT))

            pax.gui_pressed(layer, number, rl.IsMouseButtonPressed(.LEFT) ||
                rl.IsKeyPressed(.LEFT_CONTROL) || rl.IsKeyPressed(.RIGHT_CONTROL))

            released := pax.gui_released(layer, number, rl.IsMouseButtonReleased(.LEFT) ||
                rl.IsKeyReleased(.LEFT_CONTROL) || rl.IsKeyReleased(.RIGHT_CONTROL))

            if released == true { scene.state = 2 }
        }),
    })

    pax.gui_append_child(&self.gui, 2, {
        shape = {
            offset   = {0, 0, 0, 60},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {64, 64, 64, 255},
        },
    })

    pax.gui_append_child(&self.gui, 2, {
        shape = {
            offset   = {0, 0, 0, 60},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {192, 64, 64, 255},
        },
        input = pax.gui_input_from(self, proc(layer: ^pax.GUI_Layer, number: int, scene: ^Menu_Scene) {
            handle := pax.gui_find(layer, number)

            pax.gui_focused(layer, number, rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonPressed(.RIGHT))

            pax.gui_pressed(layer, number, rl.IsMouseButtonPressed(.LEFT) ||
                rl.IsKeyPressed(.LEFT_CONTROL) || rl.IsKeyPressed(.RIGHT_CONTROL))

            released := pax.gui_released(layer, number, rl.IsMouseButtonReleased(.LEFT) ||
                rl.IsKeyReleased(.LEFT_CONTROL) || rl.IsKeyReleased(.RIGHT_CONTROL))

            if released == true { scene.state = -1 }
        }),
    })
}

menu_scene_start :: proc(self: ^Menu_Scene, stage: ^Game_Stage) -> bool
{
    pax.gui_init(&self.gui)

    return true
}

menu_scene_stop :: proc(self: ^Menu_Scene)
{
    pax.gui_destroy(&self.gui)
}

menu_scene_enter :: proc(self: ^Menu_Scene)
{
    menu_scene_gui(self)
}

menu_scene_leave :: proc(self: ^Menu_Scene)
{
    pax.gui_clear(&self.gui)

    self.state = 0
}

menu_scene_input :: proc(self: ^Menu_Scene) -> int
{
    if rl.IsKeyReleased(.B) {
        if rl.IsWindowState({.WINDOW_UNDECORATED}) {
            rl.ClearWindowState({.WINDOW_UNDECORATED})
        } else {
            rl.SetWindowState({.WINDOW_UNDECORATED})
        }
    }

    area := [2]f32 {
        f32(rl.GetScreenWidth()),
        f32(rl.GetScreenHeight()),
    }

    point := rl.GetMousePosition()

    step := [3]bool {
        rl.IsKeyReleased(.RIGHT),
        rl.IsKeyReleased(.LEFT),
        rl.IsKeyReleased(.DELETE),
    }

    pax.gui_update(&self.gui, area, point, step)

    for &input, index in self.gui.inputs {
        Type :: proc(^pax.GUI_Layer, int, rawptr)

        if input.call_proc != nil {
            Type(input.call_proc)(&self.gui, index + 1, input.instance)
        }
    }

    if rl.WindowShouldClose() { self.state = -1 }

    return self.state
}

menu_scene_step :: proc(self: ^Menu_Scene, delta: f32)
{
    // empty.
}

menu_scene_draw :: proc(self: ^Menu_Scene)
{
    rl.ClearBackground({})

    for &shape, index in self.gui.shapes {
        rect := rl.Rectangle {
            shape.absolute.x,
            shape.absolute.y,
            shape.absolute.z,
            shape.absolute.w,
        }

        fill := rl.Color {
            shape.color.r,
            shape.color.g,
            shape.color.b,
            shape.color.a,
        }

        rl.DrawRectangleRec(rect, fill)

        if index + 1 == self.gui.hover {
            rl.DrawRectangleRec(rect, {
                255, 255, 255, 24,
            })
        }

        if index + 1 == self.gui.focus {
            rl.DrawRectangleLinesEx(rect, 2, {
                255, 255, 255, 255,
            })
        }
    }
}

menu_scene :: proc(self: ^Menu_Scene) -> pax.Scene
{
    value := pax.Scene {}

    value.instance = auto_cast self

    value.proc_start = auto_cast menu_scene_start
    value.proc_stop  = auto_cast menu_scene_stop
    value.proc_enter = auto_cast menu_scene_enter
    value.proc_leave = auto_cast menu_scene_leave
    value.proc_input = auto_cast menu_scene_input
    value.proc_step  = auto_cast menu_scene_step
    value.proc_draw  = auto_cast menu_scene_draw

    return value
}
