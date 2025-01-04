package test

import "core:fmt"

import rl  "vendor:raylib"
import pax "../pax"

input_move :: proc(layer: ^pax.GUI_Layer, number: int)
{
    handle := pax.gui_find(layer, number)

    pax.gui_focused(layer, number, rl.IsMouseButtonPressed(.LEFT))

    pax.gui_pressed(layer, number, rl.IsMouseButtonPressed(.LEFT) ||
        rl.IsKeyPressed(.LEFT_CONTROL) || rl.IsKeyPressed(.RIGHT_CONTROL))

    pax.gui_released(layer, number, rl.IsMouseButtonReleased(.LEFT) ||
        rl.IsKeyReleased(.LEFT_CONTROL) || rl.IsKeyReleased(.RIGHT_CONTROL))

    dragged := rl.GetMouseDelta()

    if pax.gui_dragged(layer, number, dragged != {}) {
        handle.shape.offset.xy += dragged
    }
}

input_grow :: proc(layer: ^pax.GUI_Layer, number: int)
{
    handle := pax.gui_find(layer, number)

    pax.gui_focused(layer, number, rl.IsMouseButtonPressed(.LEFT))

    pax.gui_pressed(layer, number, rl.IsMouseButtonPressed(.LEFT) ||
        rl.IsKeyPressed(.LEFT_CONTROL) || rl.IsKeyPressed(.RIGHT_CONTROL))

    pax.gui_released(layer, number, rl.IsMouseButtonReleased(.LEFT) ||
        rl.IsKeyReleased(.LEFT_CONTROL) || rl.IsKeyReleased(.RIGHT_CONTROL))

    dragged := rl.GetMouseDelta()

    if pax.gui_dragged(layer, number, dragged != {}) {
        handle.shape.offset.zw += dragged

        handle.shape.offset.z = max(handle.shape.offset.z, 0)
        handle.shape.offset.w = max(handle.shape.offset.w, 0)
    }
}

list :: proc(layer: ^pax.GUI_Layer)
{
    assert(1 == pax.gui_append_root(layer, {
        shape = {
            color = {32, 32, 32, 255},
        },
    }))

    assert(2 == pax.gui_append_child(layer, 1, {
        shape = {
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
        },
        group = pax.GUI_List_Group {
            direction = .COL,
            between   = 8,
            // stretch   = true,
        },
        input = pax.gui_input_from(input_move),
    }))

    assert(3 == pax.gui_append_child(layer, 2, {
        shape = {
            offset = {  0,   0, 100,  50},
            color  = {192,  64,  64, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))

    assert(4 == pax.gui_append_child(layer, 2, {
        shape = {
            offset = {  0,   0, 100,  50},
            color  = {192, 192,  64, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))

    assert(5 == pax.gui_append_child(layer, 2, {
        shape = {
            offset = {  0,   0, 100,  50},
            color  = { 64, 192,  64, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))

    assert(6 == pax.gui_append_child(layer, 2, {
        shape = {
            offset = {  0,   0, 100,  50},
            color  = { 64, 192, 192, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))

    assert(7 == pax.gui_append_child(layer, 2, {
        shape = {
            offset = {  0,   0, 100,  50},
            color  = { 64,  64, 192, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))

    assert(8 == pax.gui_append_child(layer, 2, {
        shape = {
            offset = {  0,   0, 100,  60},
            color  = {192,  64, 192, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))
}

flex :: proc(layer: ^pax.GUI_Layer)
{
    assert(1 == pax.gui_append_root(layer, {
        shape = {
            color = {32, 32, 32, 255},
        },
    }))

    assert(2 == pax.gui_append_child(layer, 1, {
        shape = {
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0.75, 0.5},
        },
        group = pax.GUI_Flex_Group {
            direction = .COL,
            placement = .ALIGN_CENTER,
            between   = 8,
            // stretch   = true,
        },
        input = pax.gui_input_from(input_move),
    }))

    assert(3 == pax.gui_append_child(layer, 2, {
        shape = {
            offset   = {0, 0, 100, 60},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {192, 64, 64, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))

    assert(4 == pax.gui_append_child(layer, 2, {
        shape = {
            offset   = {0, 0, 100, 50},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {192, 192, 64, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))

    assert(5 == pax.gui_append_child(layer, 2, {
        shape = {
            offset   = {0, 0, 100, 50},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {64, 192, 64, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))

    assert(6 == pax.gui_append_child(layer, 2, {
        shape = {
            offset   = {0, 0, 100, 50},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {64, 192, 192, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))

    assert(7 == pax.gui_append_child(layer, 2, {
        shape = {
            offset   = {0, 0, 100, 50},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {64, 64, 192, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))

    assert(8 == pax.gui_append_child(layer, 2, {
        shape = {
            offset   = {0, 0, 100, 60},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {192, 64, 192, 255},
        },
        input = pax.gui_input_from(input_grow),
    }))
}

main :: proc()
{
    layer := pax.GUI_Layer {}

    pax.gui_init(&layer)

    rl.SetTraceLogLevel(.NONE)
    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.InitWindow(1280, 720, "GUI")

    rl.SetExitKey(nil)

    list(&layer)

    for rl.WindowShouldClose() == false {
        size := [2]f32 {
            f32(rl.GetScreenWidth()),
            f32(rl.GetScreenHeight()),
        }

        point := rl.GetMousePosition()
        step  := [3]bool {
            rl.IsKeyReleased(.RIGHT),
            rl.IsKeyReleased(.LEFT),
            rl.IsKeyReleased(.ESCAPE),
        }

        pax.gui_update(&layer, size, point, step)

        rl.ClearBackground(rl.Color {})
        rl.BeginDrawing()

        for &input, index in layer.inputs {
            Type :: proc(^pax.GUI_Layer, int, rawptr)

            if input.call_proc != nil {
                Type(input.call_proc)(&layer, index + 1, input.instance)
            }
        }

        for &shape, index in layer.shapes {
            fill := rl.Color {
                shape.color.r,
                shape.color.g,
                shape.color.b,
                shape.color.a,
            }

            rect := rl.Rectangle {
                shape.absolute.x,
                shape.absolute.y,
                shape.absolute.z,
                shape.absolute.w,
            }

            rl.DrawRectangleRec(rect, fill)

            if index + 1 == layer.hover {
                rl.DrawRectangleRec(rect, {255, 255, 255, 64})
            }

            if index + 1 == layer.focus {
                rl.DrawRectangleLinesEx(rect, 2, {255, 255, 255, 255})
            }
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()
}
