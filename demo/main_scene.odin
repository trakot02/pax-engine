package demo

import "core:log"

import rl "vendor:raylib"

import "../pax"

Main_Scene :: struct
{
    gui:        pax.GUI_Layer,
    enable_gui: bool,

    camera: pax.Camera,
    render: pax.Render_Context,

    sprites:  pax.Sprite_Registry,
    textures: pax.Texture_Registry,
    grids:    pax.Grid_Registry,

    actors:  pax.Resource,
    players: pax.Registry(Player),

    player: int,

    state: int,
}

main_scene_gui :: proc(self: ^Main_Scene)
{
    pax.gui_append_root(&self.gui, {
        shape = { color = {32, 32, 32, 128} }
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
            color    = {64, 64, 64, 255},
        },
        input = pax.gui_input_from(self, proc(layer: ^pax.GUI_Layer, number: int, scene: ^Main_Scene) {
            pax.gui_focused(layer, number, rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonPressed(.RIGHT))

            pax.gui_pressed(layer, number, rl.IsMouseButtonPressed(.LEFT) ||
                rl.IsKeyPressed(.LEFT_CONTROL) || rl.IsKeyPressed(.RIGHT_CONTROL))

            released := pax.gui_released(layer, number, rl.IsMouseButtonReleased(.LEFT) ||
                rl.IsKeyReleased(.LEFT_CONTROL) || rl.IsKeyReleased(.RIGHT_CONTROL))

            if released == true { scene.enable_gui = false }
        }),
    })

    pax.gui_append_child(&self.gui, 2, {
        shape = {
            offset   = {0, 0, 0, 60},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {64, 64, 64, 255},
        },
        input = pax.gui_input_from(self, proc(layer: ^pax.GUI_Layer, number: int, scene: ^Main_Scene) {
            pax.gui_focused(layer, number, rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonPressed(.RIGHT))

            pax.gui_pressed(layer, number, rl.IsMouseButtonPressed(.LEFT) ||
                rl.IsKeyPressed(.LEFT_CONTROL) || rl.IsKeyPressed(.RIGHT_CONTROL))

            released := pax.gui_released(layer, number, rl.IsMouseButtonReleased(.LEFT) ||
                rl.IsKeyReleased(.LEFT_CONTROL) || rl.IsKeyReleased(.RIGHT_CONTROL))

            if released == true { scene.state = 1 }
        }),
    })

    pax.gui_append_child(&self.gui, 2, {
        shape = {
            offset   = {0, 0, 0, 60},
            origin   = {0.5, 0.5},
            relative = {0.5, 0.5, 0, 0},
            color    = {192, 64, 64, 255},
        },
        input = pax.gui_input_from(self, proc(layer: ^pax.GUI_Layer, number: int, scene: ^Main_Scene) {
            pax.gui_focused(layer, number, rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonPressed(.RIGHT))

            pax.gui_pressed(layer, number, rl.IsMouseButtonPressed(.LEFT) ||
                rl.IsKeyPressed(.LEFT_CONTROL) || rl.IsKeyPressed(.RIGHT_CONTROL))

            released := pax.gui_released(layer, number, rl.IsMouseButtonReleased(.LEFT) ||
                rl.IsKeyReleased(.LEFT_CONTROL) || rl.IsKeyReleased(.RIGHT_CONTROL))

            if released == true { scene.state = -1 }
        }),
    })
}

main_scene_start :: proc(self: ^Main_Scene, stage: ^Game_Stage) -> bool
{
    pax.gui_init(&self.gui)

    pax.sprite_registry_init(&self.sprites)
    pax.texture_registry_init(&self.textures)
    pax.grid_registry_init(&self.grids)

    pax.resource_init(&self.actors)
    pax.registry_init(&self.players)

    self.render.camera   = &self.camera
    self.render.textures = &self.textures
    self.render.sprites  = &self.sprites

    self.player  = pax.resource_create(&self.actors) or_return
    player      := pax.registry_insert(&self.players, self.player, Player {}) or_return

    if main_scene_load(self) == false {
        log.errorf("Main_Scene: Unable to load")

        return false
    }

    return true
}

main_scene_stop :: proc(self: ^Main_Scene)
{
    main_scene_unload(self)

    pax.gui_destroy(&self.gui)
}

main_scene_load :: proc(self: ^Main_Scene) -> bool
{
    textures := [?]string {
        "data/main_scene/texture/tiles.png",
        "data/main_scene/texture/chars.png",
    }

    sprites := [?]string {
        "data/main_scene/sprite/tiles.json",
        "data/main_scene/sprite/chars.json",
    }

    grids := [?]string {
        "data/main_scene/grid/grid1.json",
        "data/main_scene/grid/grid2.json",
    }

    for name in textures {
        pax.texture_registry_read(&self.textures, name) or_return
    }

    for name in sprites {
        pax.sprite_registry_read(&self.sprites, name) or_return
    }

    for name in grids {
        pax.grid_registry_read(&self.grids, name) or_return
    }

    player := pax.registry_find(&self.players, self.player) or_return

    player.visual.sprite = 2
    player.visual.chain  = 5

    player.transform.point = {48, 48}
    player.transform.scale = { 1,  1}

    player.motion.point = {48, 48}
    player.motion.speed = 128
    player.motion.grid  = 1

    player.camera = &self.camera

    grid := pax.grid_registry_find(&self.grids, player.motion.grid) or_return

    self.camera.size  = WINDOW_SIZE
    self.camera.scale = {4, 4}

    self.camera.offset = [2]f32 {
        WINDOW_SIZE.x / 2 - f32(grid.tile.x / 2),
        WINDOW_SIZE.y / 2 - f32(grid.tile.y / 2),
    }

    self.camera.bounds = [4]f32 {
        0, 0,
        f32(grid.tile.x) * f32(grid.size.x),
        f32(grid.tile.y) * f32(grid.size.y),
    }

    value := pax.grid_find_value(grid, 1, 3,
        pax.point_to_cell(grid, player.transform.point)) or_return

    value^ = self.player

    size := [2]f32 {
        WINDOW_SIZE.x * self.camera.scale.x,
        WINDOW_SIZE.y * self.camera.scale.y,
    }

    rl.SetWindowSize(i32(size.x), i32(size.y))

    screen := [2]f32 {
        f32(rl.GetMonitorWidth(0)),
        f32(rl.GetMonitorHeight(0)),
    }

    size   /= 2.0
    screen /= 2.0

    rl.SetWindowPosition(
        i32(screen.x - size.x),
        i32(screen.y - size.y),
    )

    return true
}

main_scene_unload :: proc(self: ^Main_Scene)
{
    // empty.
}

main_scene_enter :: proc(self: ^Main_Scene)
{
    main_scene_gui(self)
}

main_scene_leave :: proc(self: ^Main_Scene)
{
    pax.gui_clear(&self.gui)

    self.state      = 0
    self.enable_gui = false
}

main_scene_input :: proc(self: ^Main_Scene) -> int
{
    if rl.IsKeyReleased(.ESCAPE) {
        self.enable_gui = !self.enable_gui
    }

    if rl.IsWindowResized() {
        self.camera.scale.x = f32(rl.GetScreenWidth())  / WINDOW_SIZE.x
        self.camera.scale.y = f32(rl.GetScreenHeight()) / WINDOW_SIZE.y
    }

    if rl.IsKeyReleased(.B) {
        if rl.IsWindowState({.WINDOW_UNDECORATED}) {
            rl.ClearWindowState({.WINDOW_UNDECORATED})
        } else {
            rl.SetWindowState({.WINDOW_UNDECORATED})
        }
    }

    if self.enable_gui == true {
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
    } else {
        player, _ := pax.registry_find(&self.players, self.player)

        if player != nil {
            if rl.IsKeyPressed(.D) { player.controls.east  = true }
            if rl.IsKeyPressed(.W) { player.controls.north = true }
            if rl.IsKeyPressed(.A) { player.controls.west  = true }
            if rl.IsKeyPressed(.S) { player.controls.south = true }

            if rl.IsKeyReleased(.D) { player.controls.east  = false }
            if rl.IsKeyReleased(.W) { player.controls.north = false }
            if rl.IsKeyReleased(.A) { player.controls.west  = false }
            if rl.IsKeyReleased(.S) { player.controls.south = false }
        }
    }

    if rl.WindowShouldClose() { self.state = -1 }

    return self.state
}

main_scene_step :: proc(self: ^Main_Scene, delta: f32)
{
    for index in 0 ..< self.players.count {
        player := &self.players.values[index]

        angle := controls_angle(&player.controls)
        grid  := pax.grid_registry_find(&self.grids, player.motion.grid) or_continue

        switch angle {
            case { 0, -1}: player.visual.chain = 9
            case { 1, -1}: player.visual.chain = 10
            case { 1,  0}: player.visual.chain = 11
            case { 1,  1}: player.visual.chain = 12
            case { 0,  1}: player.visual.chain = 13
            case {-1,  1}: player.visual.chain = 14
            case {-1,  0}: player.visual.chain = 15
            case {-1, -1}: player.visual.chain = 16
        }

        if angle.x == 0 && angle.y == 0 { player.visual.chain = 5 }

        for layer in 1 ..= len(grid.stacks[0]) {
            angle = motion_test(&player.motion, &self.grids, angle, 1, layer)

            if angle.x == 0 && angle.y == 0 {
                break
            }
        }

        gate := motion_gate(&player.motion, &self.grids, 3, 1)

        if gate != nil {
            motion_change(&player.motion, &self.grids, 1, 3, gate^)
        }

        if motion_step(&player.motion, &self.grids, angle, delta) {
            motion_grid(&player.motion, &self.grids, angle, 1, 3)
        }

        player.transform.point = player.motion.point

        if player.camera != nil {
            pax.camera_move(&self.camera, player.transform.point)
        }

        sprite := pax.sprite_registry_find(&self.sprites, player.visual.sprite) or_continue

        pax.sprite_update_chain(sprite, player.visual.chain, delta)
    }
}

main_scene_draw_sprite_layer :: proc(self: ^Main_Scene, layer: int, cell: [2]int) -> bool
{
    player := pax.registry_find(&self.players, self.player)           or_return
    grid   := pax.grid_registry_find(&self.grids, player.motion.grid) or_return

    value := pax.grid_find_value(grid, 2, layer, cell) or_return
    point := pax.cell_to_point(grid, cell)

    visual := pax.Visual {
        sprite = 1,
        frame  = value^,
    }

    transf := pax.Transform {
        point = point,
        scale = {1, 1},
    }

    pax.render_draw_sprite(&self.render, visual, transf)

    return true
}

main_scene_draw_player_layer :: proc(self: ^Main_Scene, layer: int, cell: [2]int) -> bool
{
    player := pax.registry_find(&self.players, self.player)           or_return
    grid   := pax.grid_registry_find(&self.grids, player.motion.grid) or_return

    value := pax.grid_find_value(grid, 2, layer, cell) or_return
    point := pax.cell_to_point(grid, cell)

    actor := pax.registry_find(&self.players, value^) or_return

    pax.render_draw_sprite(&self.render, player.visual, player.transform)

    return false
}

main_scene_draw :: proc(self: ^Main_Scene)
{
    pax.render_clear(&self.render, {50, 50, 50, 255})

    player, _ := pax.registry_find(&self.players, self.player)

    if player == nil { return }

    grid, _ := pax.grid_registry_find(&self.grids, player.motion.grid)

    if grid == nil { return }

    area := pax.camera_grid_area(&self.camera, grid)

    for row in area[0].y ..= area[1].y {
        for col in area[0].x ..= area[1].x {
            main_scene_draw_sprite_layer(self, 1, {col, row})
            main_scene_draw_sprite_layer(self, 2, {col, row})
        }
    }

    for row in area[0].y ..= area[1].y {
        for col in area[0].x ..= area[1].x {
            main_scene_draw_sprite_layer(self, 3, {col, row})
            main_scene_draw_player_layer(self, 4, {col, row})
        }
    }

    if self.enable_gui == true {
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
}

main_scene :: proc(self: ^Main_Scene) -> pax.Scene
{
    value := pax.Scene {}

    value.instance = auto_cast self

    value.proc_start = auto_cast main_scene_start
    value.proc_stop  = auto_cast main_scene_stop
    value.proc_enter = auto_cast main_scene_enter
    value.proc_leave = auto_cast main_scene_leave
    value.proc_input = auto_cast main_scene_input
    value.proc_step  = auto_cast main_scene_step
    value.proc_draw  = auto_cast main_scene_draw

    return value
}
