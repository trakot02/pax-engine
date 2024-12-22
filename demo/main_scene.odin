package demo

import "core:log"

import sdl  "vendor:sdl2"
import sdli "vendor:sdl2/image"

import "../pax"

Main_Scene :: struct
{
    window:   ^pax.Window,
    renderer: ^pax.Renderer,

    camera: pax.Camera,
    render: pax.Render_Context,

    keyboard: pax.Keyboard,

    images:  pax.Image_Registry,
    sprites: pax.Sprite_Registry,
    grids:   pax.Grid_Registry,

    world:        pax.World,
    player_group: pax.Group(Player),

    player: int,

    state: int,
}

main_scene_player_on_key_release :: proc(event: sdl.KeyboardEvent, self: ^Player)
{
    #partial switch event.keysym.sym {
        case .D, .RIGHT: self.controls.east  = false
        case .W, .UP:    self.controls.north = false
        case .A, .LEFT:  self.controls.west  = false
        case .S, .DOWN:  self.controls.south = false
    }
}

main_scene_player_on_key_press :: proc(event: sdl.KeyboardEvent, self: ^Player)
{
    #partial switch event.keysym.sym {
        case .D, .RIGHT: self.controls.east  = true
        case .W, .UP:    self.controls.north = true
        case .A, .LEFT:  self.controls.west  = true
        case .S, .DOWN:  self.controls.south = true
    }
}

main_scene_on_key_release :: proc(event: sdl.KeyboardEvent, self: ^Main_Scene)
{
    #partial switch event.keysym.sym {
        case .ESCAPE: self.state = -1

        case .R: {
            main_scene_unload(self)

            if main_scene_load(self) == false {
                self.state = -1
            }
        }

        case .P, .PLUS,  .KP_PLUS:  self.camera.scale += 1
        case .M, .MINUS, .KP_MINUS: self.camera.scale -= 1

        case .B: {
            pax.window_set_border(self.window, false)
            pax.window_set_origin(self.window, {0, 0})
        }
    }

    pax.window_set_size(self.window, WINDOW_SIZE * self.camera.scale)
}

main_scene_on_close :: proc(self: ^Main_Scene)
{
    self.state = -1
}

main_scene_start :: proc(self: ^Main_Scene, stage: ^Game_Stage) -> bool
{
    self.window   = &stage.window
    self.renderer = &stage.renderer

    pax.keyboard_init(&self.keyboard)

    pax.image_registry_init(&self.images, self.renderer)
    pax.sprite_registry_init(&self.sprites)
    pax.grid_registry_init(&self.grids)

    pax.world_init(&self.world)
    pax.group_init(&self.player_group)

    self.render.renderer = self.renderer
    self.render.camera   = &self.camera
    self.render.images   = &self.images
    self.render.sprites  = &self.sprites

    self.player  = pax.world_create_actor(&self.world)               or_return
    player      := pax.group_insert(&self.player_group, self.player) or_return

    pax.signal_insert(&self.keyboard.release, player, main_scene_player_on_key_release)
    pax.signal_insert(&self.keyboard.press,   player, main_scene_player_on_key_press)
    pax.signal_insert(&self.keyboard.release, self,   main_scene_on_key_release)
    pax.signal_insert(&self.window.close,     self,   main_scene_on_close)

    if main_scene_load(self) == false {
        log.errorf("Main_Scene: Unable to load")

        return false
    }

    pax.window_show(self.window)

    return true
}

main_scene_stop :: proc(self: ^Main_Scene)
{
    pax.window_hide(self.window)

    main_scene_unload(self)
}

main_scene_load :: proc(self: ^Main_Scene) -> bool
{
    images := [?]string {
        "data/main_scene/image/tiles.png",
        "data/main_scene/image/chars.png",
    }

    sprites := [?]string {
        "data/main_scene/sprite/tiles.json",
        "data/main_scene/sprite/chars.json",
    }

    grids := [?]string {
        "data/main_scene/grid/grid1.json",
        "data/main_scene/grid/grid2.json",
    }

    for name in images {
        pax.image_registry_read(&self.images, name) or_return
    }

    for name in sprites {
        pax.sprite_registry_read(&self.sprites, name) or_return
    }

    for name in grids {
        pax.grid_registry_read(&self.grids, name) or_return
    }

    player := pax.group_find(&self.player_group, self.player) or_return

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

    pax.window_set_size(self.window, WINDOW_SIZE * self.camera.scale)

    return true
}

main_scene_unload :: proc(self: ^Main_Scene)
{
    // empty.
}

main_scene_enter :: proc(self: ^Main_Scene)
{
    // empty.
}

main_scene_leave :: proc(self: ^Main_Scene)
{
    // empty.
}

main_scene_input :: proc(self: ^Main_Scene, event: sdl.Event) -> int
{
    pax.keyboard_emit(&self.keyboard, event)
    pax.window_emit(self.window, event)

    return self.state
}

main_scene_step :: proc(self: ^Main_Scene, delta: f32)
{
    for index in 0 ..< self.player_group.count {
        player := &self.player_group.values[index]

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
    player := pax.group_find(&self.player_group, self.player)         or_return
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
    player := pax.group_find(&self.player_group, self.player)         or_return
    grid   := pax.grid_registry_find(&self.grids, player.motion.grid) or_return

    value := pax.grid_find_value(grid, 2, layer, cell) or_return
    point := pax.cell_to_point(grid, cell)

    actor := pax.group_find(&self.player_group, value^) or_return

    pax.render_draw_sprite(&self.render, player.visual, player.transform)

    return false
}

main_scene_draw :: proc(self: ^Main_Scene)
{
    pax.render_clear(&self.render, {50, 50, 50, 255})

    player, _ := pax.group_find(&self.player_group, self.player)

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

    pax.render_apply(&self.render)
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
