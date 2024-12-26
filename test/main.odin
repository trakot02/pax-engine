package test

import "core:fmt"

import rl "vendor:raylib"

import gui "../pax/gui"

main :: proc()
{
    root := gui.Element {
        offset = {0, 0, 1280, 720},
    }

    list := gui.Element {
        relative = {0.5, 0.5, 0, 0},
        origin   = {0.5, 0.5},
        layout   = gui.List_Layout {
            spacing   = 16,
            direction = .HOR,
            // alignment = .STRETCH,
        },
    }

    item1 := gui.Element {
        relative = {0.5, 0.5, 0, 0},
        offset   = {0, 0, 512, 64},
        origin   = {0.5, 0.5},
    }

    item2 := gui.Element {
        relative = {0.5, 0.5, 0, 0},
        offset   = {0, 0, 256, 128},
        origin   = {0.5, 0.5},
    }

    item3 := gui.Element {
        relative = {0.5, 1, 0, 0},
        offset   = {0, 0, 96, 96},
        origin   = {0.5, 1},
    }

    root.first   = &list
    root.last    = &list
    list.parent  = &root

    list.first  = &item1
    list.last   = &item3

    item1.parent = &list
    item1.next   = &item2

    item2.parent = &list
    item2.prev   = &item1
    item2.next   = &item3

    item3.parent = &list
    item3.prev   = &item2

    rl.SetWindowState({.WINDOW_RESIZABLE})

    rl.InitWindow(1280, 720, "GUI")

    camera := rl.Camera2D { zoom = 1 }

    for rl.WindowShouldClose() == false {
        if rl.IsWindowResized() {
            root.offset.z = f32(rl.GetScreenWidth())
            root.offset.w = f32(rl.GetScreenHeight())
        }

        gui.compute(&root)

        rl.ClearBackground(rl.Color {3 = 255})

        rl.BeginDrawing()
        rl.BeginMode2D(camera)

        rl.DrawRectangleRec(
            rl.Rectangle {
                root.absolute.x,
                root.absolute.y,
                root.absolute.z,
                root.absolute.w,
            },
            rl.Color {0, 0, 0, 255},
        )

        rl.DrawRectangleRec(
            rl.Rectangle {
                list.absolute.x,
                list.absolute.y,
                list.absolute.z,
                list.absolute.w,
            },
            rl.Color {255, 255, 255, 255},
        )

        rl.DrawRectangleRec(
            rl.Rectangle {
                item1.absolute.x,
                item1.absolute.y,
                item1.absolute.z,
                item1.absolute.w,
            },
            rl.Color {255, 0, 0, 128},
        )

        rl.DrawRectangleRec(
            rl.Rectangle {
                item2.absolute.x,
                item2.absolute.y,
                item2.absolute.z,
                item2.absolute.w,
            },
            rl.Color {0, 255, 0, 128},
        )

        rl.DrawRectangleRec(
            rl.Rectangle {
                item3.absolute.x,
                item3.absolute.y,
                item3.absolute.z,
                item3.absolute.w,
            },
            rl.Color {0, 0, 255, 128},
        )

        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}
