package test

import "core:log"
import "core:fmt"

import rl  "vendor:raylib"
import pax "../pax"
import gui "../pax/gui"
import res "../pax/res"

App_State :: struct
{
    gui:      gui.State,
    textures: res.Holder(res.Texture),
    fonts:    res.Holder(res.Font),

    atlas: int,
}

main :: proc()
{
    context.logger = log.create_console_logger(lowest = .Debug)

    app := App_State {}

    value   := f32(0)
    color_1 := [4]u8 {224, 96, 96, 255}
    color_2 := [4]u8 {96, 224, 96, 255}

    rl.SetWindowState({.WINDOW_RESIZABLE, .WINDOW_HIDDEN})
    rl.InitWindow(1280, 720, "GUI")

    res.holder_init(&app.textures)
    res.holder_init(&app.fonts)
    gui.init(&app.gui, &app.textures, &app.fonts)

    app.atlas, _ = res.holder_insert(&app.textures,
        res.texture_read("data/atlas.png"))

    rl.ClearWindowState({.WINDOW_HIDDEN})

    for rl.WindowShouldClose() == false {
        gui.update(&app.gui, rl.GetMouseDelta())

        root, _ := gui.insert_root(&app.gui, {
            offset = {0, 0,
                f32(rl.GetScreenWidth()),
                f32(rl.GetScreenHeight()),
            },
            fill = {32, 32, 32, 255},
        })

        list, _ := gui.insert_child(&app.gui, root, gui.Element {
            // offset = {0, 0, 256, 0},
            origin = {0.5, 0.5},
            factor = {0.5, 0.5, 0.25, 0.5},
            fill   = {255, 255, 255, 32},
            group  = gui.List_Group {
                direction = .COL,
                between   = 8,
            }
        })

        button_1, _ := gui.insert_child(&app.gui, list, gui.Element {
            offset = {0, 0, 256, 48},
            origin = {0.5, 0.5},
            factor = {0.5, 0.5, 0, 0},
            fill   = color_1,
        })

        button_2, _ := gui.insert_child(&app.gui, list, gui.Element {
            offset = {0, 0, 64, 48},
            origin = {0.5, 0.5},
            factor = {0.5, 0.5, 0, 0},
            fill   = color_2,
        })

        slider_1, _ := gui.insert_child(&app.gui, list, gui.Element {
            origin = {0.5, 0.5},
            factor = {0.5, 0.5, 4, 4},
            group  = gui.Image_Group {
                slot = app.atlas,
            }
        })

        gui.layout(&app.gui)

        button_info := gui.Button_Info {
            pressed  = b8(rl.IsMouseButtonPressed(.LEFT)),
            released = b8(rl.IsMouseButtonReleased(.LEFT)),
        }

        slider_info := gui.Slider_Info {
            pressed  = b8(rl.IsMouseButtonPressed(.LEFT)),
            released = b8(rl.IsMouseButtonReleased(.LEFT)),
            movement = app.gui.delta.x,
            range    = {0, 255},
            step     = 1,
        }

        if gui.button(&app.gui, button_1, button_info) {
            temp := color_1

            color_1 = color_2
            color_2 = temp
        }

        if gui.button(&app.gui, button_2, button_info) {
            temp := color_1

            color_1 = color_2
            color_2 = temp
        }

        gui.slider(&app.gui, slider_1, slider_info, &value)

        rl.ClearBackground({255, 255, 255, 255})
        rl.BeginDrawing()

        for slot in 1 ..= len(app.gui.nodes) {
            handle := gui.find(&app.gui, slot)

            rl.DrawRectangleRec({
                handle.bounds.x, handle.bounds.y,
                handle.bounds.z, handle.bounds.w,
            }, {
                handle.fill.r, handle.fill.g,
                handle.fill.b, handle.fill.a,
            })

            if gui.is_active(&app.gui, handle) {
                rl.DrawRectangleLinesEx({
                    handle.bounds.x, handle.bounds.y,
                    handle.bounds.z, handle.bounds.w,
                }, 2, {255, 255, 255, 255})
            }

            if gui.is_target(&app.gui, handle) {
                rl.DrawRectangleRec({
                    handle.bounds.x, handle.bounds.y,
                    handle.bounds.z, handle.bounds.w,
                }, {255, 255, 255, 32})
            }

            #partial switch &group in handle.group {
                case gui.Image_Group: {
                    texture := res.holder_find(app.gui.textures, group.slot)

                    if texture.slot != 0 {
                        rl.DrawTexturePro(texture.value^, {
                            0, 0, f32(texture.value.width), f32(texture.value.height)
                        }, {
                            handle.bounds.x, handle.bounds.y,
                            handle.bounds.z, handle.bounds.w,
                        }, {}, 0, {255, 255, u8(value), 255})
                    }
                }
            }
        }

        rl.EndDrawing()
    }

    gui.destroy(&app.gui)

    rl.CloseWindow()
}
