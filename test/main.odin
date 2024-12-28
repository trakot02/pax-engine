package test

import "core:fmt"

import rl "vendor:raylib"

import gui "../pax/gui"

list :: proc(state: ^gui.State)
{
    /* 1 */ gui.append_child(state, 0, gui.Element {
        fill = {32, 32, 32, 255},
    })

    /* 2 */ gui.append_child(state, 1, gui.Element {
        layout = gui.List_Layout {
            direction = .COL,
            between   = 8,
            stretch   = true,
        },
        relative = {0.5, 0.5, 0, 0},
        origin   = {0.5, 0.5},
        offset   = {0, 0, 8, 8},
        fill     = {255, 255, 255, 255},
    })

    /* 3 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0, 0},
        origin   = {0.5, 0.5},
        offset   = {0, 0, 96, 16},
        fill     = {96, 0, 0, 255},
        border   = {255, 255, 255, 255},
    })

    /* 4 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0, 0},
        origin   = {0.5, 0.5},
        offset   = {0, 0, 96, 32},
        fill     = {96, 96, 0, 255},
        border   = {255, 255, 255, 255},
    })

    /* 5 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0, 0},
        origin   = {0.5, 0.5},
        offset   = {0, 0, 96, 32},
        fill     = {0, 96, 0, 255},
        border   = {255, 255, 255, 255},
    })

    /* 6 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0, 0},
        origin   = {0.5, 0.5},
        offset   = {0, 0, 96, 32},
        fill     = {0, 96, 96, 255},
        border   = {255, 255, 255, 255},
    })

    /* 7 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0, 0},
        origin   = {0.5, 0.5},
        offset   = {0, 0, 96, 16},
        fill     = {0, 0, 96, 255},
        border   = {255, 255, 255, 255},
    })

    /* 8 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0, 0},
        origin   = {0.5, 0.5},
        offset   = {0, 0, 96, 32},
        fill     = {96, 0, 96, 255},
        border   = {255, 255, 255, 255},
    })
}

flex :: proc(state: ^gui.State)
{
    /* 1 */ gui.append_child(state, 0, gui.Element {
        fill = {32, 32, 32, 255},
    })

    /* 2 */ gui.append_child(state, 1, gui.Element {
        layout = gui.Flex_Layout {
            direction = .COL,
            placement = .ALIGN_END,
            between   = 8,
            stretch   = true,
        },
        relative = {0, 0.5, 0.33, 1},
        origin   = {0, 0.5},
        offset   = {8, 0, -16, -16}
    })

    /* 3 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0.5, 0.5},
        origin   = {0.5, 0.5},
        fill     = {128, 96, 96, 255},
    })

    /* 4 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0.5, 0.5},
        origin   = {0.5, 0.5},
        fill     = {128, 128, 96, 255},
    })

    /* 5 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0.5, 0.5},
        origin   = {0.5, 0.5},
        fill     = {96, 128, 96, 255},
    })

    /* 6 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0.5, 0.5},
        origin   = {0.5, 0.5},
        fill     = {96, 128, 128, 255},
    })

    /* 7 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0.5, 0.5},
        origin   = {0.5, 0.5},
        fill     = {96, 96, 128, 255},
    })

    /* 8 */ gui.append_child(state, 2, gui.Element {
        relative = {0.5, 0.5, 0.5, 0.5},
        origin   = {0.5, 0.5},
        fill     = {148, 112, 148, 255},
    })
}

main :: proc()
{
    state := gui.State {}

    gui.init(&state)

    flex(&state)

    gui.update_layout(&state, 1, {1280, 720})

    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.InitWindow(1280, 720, "GUI")

    camera := rl.Camera2D { zoom = 1 }

    for rl.WindowShouldClose() == false {
        if rl.IsWindowResized() {
            size := [2]f32 {
                f32(rl.GetScreenWidth()),
                f32(rl.GetScreenHeight()),
            }

            gui.update_layout(&state, 1, size)
        }

        gui.update_mouse_focus(&state, 1, rl.GetMousePosition())

        gui.update_keyboard_focus(&state, 1, {
            rl.IsKeyReleased(.LEFT),
            rl.IsKeyReleased(.RIGHT),
        })

        rl.ClearBackground(rl.Color {})

        rl.BeginDrawing()
        rl.BeginMode2D(camera)

        for &elem, index in state.values {
            fill := rl.Color {
                elem.fill.r,
                elem.fill.g,
                elem.fill.b,
                elem.fill.a,
            }

            rect := rl.Rectangle {
                elem.absolute.x,
                elem.absolute.y,
                elem.absolute.z,
                elem.absolute.w,
            }

            rl.DrawRectangleRec(rect, fill)
        }

        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}
