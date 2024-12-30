package test

import "core:fmt"

import rl "vendor:raylib"

import gui "../pax/gui"
import pax "../pax"

list :: proc(state: ^gui.State)
{
    /* 1 */ gui.append_child(state, 0, {})

    /* 2 */ gui.append_child(state, 1, {
        shape = {
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
        },
        layout = gui.List_Layout {
            direction = .ROW,
            between   = 8,
        },
    })

    /* 3 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {192, 112, 112, 255},
        },
    })

    /* 4 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {192, 192, 112, 255},
        },
    })

    /* 5 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {112, 192, 112, 255},
        },
    })

    /* 6 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {112, 192, 192, 255},
        },
    })

    /* 7 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {112, 112, 192, 255},
        },
    })

    /* 8 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {192, 112, 192, 255},
        },
    })
}

flex :: proc(state: ^gui.State)
{
    /* 1 */ gui.append_child(state, 0, {})

    /* 2 */ gui.append_child(state, 1, {
        shape = {
            origin   = {0, 0.5},
            relative = {0, 0.5, 0.33, 1},
        },
        layout = gui.Flex_Layout {
            direction = .COL,
            placement = .FILL,
            between   = 8,
            stretch   = true,
        }
    })

    /* 3 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {192, 112, 112, 255},
        },
    })

    /* 4 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {192, 192, 112, 255},
        },
    })

    /* 5 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {112, 192, 112, 255},
        },
    })

    /* 6 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {112, 192, 192, 255},
        },
    })

    /* 7 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {112, 112, 192, 255},
        },
    })

    /* 8 */ gui.append_child(state, 2, {
        shape = {
            offset = {0, 0, 100, 50},
        },
        color = {
            fill = {192, 112, 192, 255},
        },
    })
}

main :: proc()
{
    state := gui.State {}

    gui.init(&state)

    list(&state)

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
            rl.IsKeyReleased(.RIGHT) || rl.IsKeyReleased(.D),
            rl.IsKeyReleased(.LEFT)  || rl.IsMouseButtonReleased(.RIGHT),
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

            if index + 1 == state.focus {
                rl.DrawRectangleLinesEx(rect, 2, border)
            }

            if index + 1 == state.hover {
                rl.DrawRectangleLinesEx(rect, 2, border)
            }
        }

        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}
