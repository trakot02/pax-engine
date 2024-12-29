package test

import "core:fmt"

import rl "vendor:raylib"

import gui "../pax/gui"
import pax "../pax"

list :: proc(state: ^gui.State)
{
    /* 1 */ gui.append_child(state, 0, {}, {
        fill = {32, 32, 32, 255},
    }, nil)

    /* 2 */ gui.append_child(state, 1, {
        offset   = {  8,   8, 16, 16},
        origin   = {0.5, 0.5},
        relative = {0.5, 0.5,  0,  0},
    }, {}, gui.List_Layout {
        direction = .ROW,
        between   = 8,
    })

    /* 3 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {192, 112, 112, 255},
    }, nil)

    /* 4 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {192, 192, 112, 255},
    }, nil)

    /* 5 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {112, 192, 112, 255},
    }, nil)

    /* 6 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {112, 192, 192, 255},
    }, nil)

    /* 7 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {112, 112, 192, 255},
    }, nil)

    /* 8 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {192, 112, 192, 255},
    }, nil)
}

flex :: proc(state: ^gui.State)
{
    /* 1 */ gui.append_child(state, 0, {}, {
        fill = {32, 32, 32, 255},
    }, nil)

    /* 2 */ gui.append_child(state, 1, {
        offset   = {  8,   8, 16,  16},
        origin   = {0.5, 0.5},
        relative = {0.5, 0.5,  1, 0.2},
    }, {}, gui.Flex_Layout {
        direction = .ROW,
        placement = .SPACE_APART,
        between   = 8,
        stretch   = true,
    })

    /* 3 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {192, 112, 112, 255},
    }, nil)

    /* 4 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {192, 192, 112, 255},
    }, nil)

    /* 5 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {112, 192, 112, 255},
    }, nil)

    /* 6 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {112, 192, 192, 255},
    }, nil)

    /* 7 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {112, 112, 192, 255},
    }, nil)

    /* 8 */ gui.append_child(state, 2, {
        offset = {0, 0, 100, 100},
    }, {
        fill = {192, 112, 192, 255},
    }, nil)
}

main :: proc()
{
    state := gui.State {}

    gui.init(&state)

    flex(&state)

    elem := gui.find(&state, 3)

    gui.update_layout(&state, {1280, 720})

    rl.SetTraceLogLevel(.NONE)
    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.InitWindow(1280, 720, "GUI")

    camera := rl.Camera2D { zoom = 1 }

    for rl.WindowShouldClose() == false {
        if rl.IsWindowResized() {
            size := [2]f32 {
                f32(rl.GetScreenWidth()),
                f32(rl.GetScreenHeight()),
            }

            gui.update_layout(&state, size)
        }

        gui.update_hover(&state, rl.GetMousePosition())

        gui.update_focus(&state, {
            rl.IsKeyReleased(.RIGHT),
            rl.IsKeyReleased(.LEFT),
        })

        rl.ClearBackground(rl.Color {})

        rl.BeginDrawing()
        rl.BeginMode2D(camera)

        for &elem, index in state.elems {
            fill := rl.Color {
                elem.color.fill.r,
                elem.color.fill.g,
                elem.color.fill.b,
                elem.color.fill.a,
            }

            border := rl.Color {
                elem.color.border.r,
                elem.color.border.g,
                elem.color.border.b,
                elem.color.border.a,
            }

            rect := rl.Rectangle {
                elem.shape.absolute.x,
                elem.shape.absolute.y,
                elem.shape.absolute.z,
                elem.shape.absolute.w,
            }

            rl.DrawRectangleRec(rect, fill)
            rl.DrawRectangleLinesEx(rect, 2, border)

            if index + 1 == state.focus {
                rl.DrawRectangleLinesEx(rect, 2, {255, 255, 255, 255})
            }
        }

        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}
