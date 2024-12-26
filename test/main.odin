package test

import "core:fmt"

import rl "vendor:raylib"

import gui "../pax/gui"

main :: proc()
{
    elems := make([dynamic]gui.Element)

    append(&elems, gui.Element {
        color  = {32, 32, 32, 255},
        first  = 2,
    })

    append(&elems, gui.Element {
        layout = gui.List_Layout {
            direction = .COL,
            alignment = .STRETCH,
            spacing   = 8,
        },
        relative = {0.5, 0.5, 0, 0},
        origin   = {0.5, 0.5},
        parent   = 1,
        first    = 2,
        last     = 5,
    })

    append(&elems, gui.Element {
        relative = {0.5, 0.5, 0, 0},
        offset   = {0, 0, 512, 64},
        origin   = {0.5, 0.5},
        color    = {128, 0, 0, 255},
        parent   = 2,
        next     = 4,
    })

    append(&elems, gui.Element {
        relative = {0.5, 0.5, 0, 0},
        offset   = {0, 0, 256, 64},
        origin   = {0.5, 0.5},
        color    = {0, 128, 0, 255},
        parent   = 2,
        prev     = 3,
        next     = 5,
    })

    append(&elems, gui.Element {
        relative = {0.5, 1, 0, 0},
        offset   = {0, 0, 96, 64},
        origin   = {0.5, 1},
        color    = {0, 0, 128, 255},
        parent   = 2,
        prev     = 4,
    })

    gui.update_layout(elems, 1, {
        f32(rl.GetScreenWidth()),
        f32(rl.GetScreenHeight()),
    })

    rl.SetWindowState({.WINDOW_RESIZABLE})

    rl.InitWindow(1280, 720, "GUI")

    camera := rl.Camera2D { zoom = 1 }

    for rl.WindowShouldClose() == false {
        if rl.IsWindowResized() {
            gui.update_layout(elems, 1, {
                f32(rl.GetScreenWidth()),
                f32(rl.GetScreenHeight()),
            })
        }

        gui.update_mouse(elems, 1, rl.GetMousePosition())

        rl.ClearBackground(rl.Color {})

        rl.BeginDrawing()
        rl.BeginMode2D(camera)

        for elem in elems {
            color := rl.Color {
                elem.color.r,
                elem.color.g,
                elem.color.b,
                elem.color.a,
            }

            rect := rl.Rectangle {
                elem.absolute.x,
                elem.absolute.y,
                elem.absolute.z,
                elem.absolute.w,
            }

            rl.DrawRectangleRec(rect, color)

            if elem.state & {.MOUSE_FOCUS} != {} {
                rl.DrawRectangleLinesEx(rect, 2, {255, 255, 255, 255})
            }
        }

        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}
