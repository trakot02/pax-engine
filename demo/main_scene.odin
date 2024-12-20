package demo

import "core:log"

import sdl  "vendor:sdl2"
import sdli "vendor:sdl2/image"

import "../pax"

Main_Scene :: struct
{
    window:   ^pax.Window,
    keyboard: pax.Keyboard,

    image_ctx:  pax.Image_Context,
    sprite_ctx: pax.Sprite_Context,
    grid_ctx:   pax.Grid_Context,

    image_reg:  pax.Registry(pax.Image),
    sprite_reg: pax.Registry(pax.Sprite),
    grid_reg:   pax.Registry(pax.Grid),

    world:        pax.World,
    player_group: pax.Group(Player),

    render: pax.Render_State,
    camera: pax.Camera,

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
    }

    pax.window_resize(self.window, WINDOW_SIZE * self.camera.scale)
}

main_scene_on_close :: proc(self: ^Main_Scene)
{
    self.state = -1
}

main_scene_start :: proc(self: ^Main_Scene, stage: ^Game_Stage) -> bool
{
    self.window = &stage.window

    pax.keyboard_init(&self.keyboard)

    self.image_ctx.renderer   = self.window.renderer
    self.sprite_ctx.allocator = context.allocator
    self.grid_ctx.allocator   = context.allocator

    self.image_reg  = pax.image_registry(&self.image_ctx)
    self.sprite_reg = pax.sprite_registry(&self.sprite_ctx)
    self.grid_reg   = pax.grid_registry(&self.grid_ctx)

    pax.registry_init(&self.image_reg)
    pax.registry_init(&self.sprite_reg)
    pax.registry_init(&self.grid_reg)

    pax.world_init(&self.world)
    pax.group_init(&self.player_group)

    self.render.renderer = auto_cast self.window.renderer
    self.render.camera   = &self.camera
    self.render.images   = &self.image_reg
    self.render.sprites  = &self.sprite_reg

    self.player  = pax.world_create_actor(&self.world) or_return
    player      := pax.group_insert(&self.player_group, self.player) or_return

    pax.signal_insert(&self.keyboard.release, player, main_scene_player_on_key_release)
    pax.signal_insert(&self.keyboard.press,   player, main_scene_player_on_key_press)
    pax.signal_insert(&self.keyboard.release, self,   main_scene_on_key_release)
    pax.signal_insert(&self.window.close,     self,   main_scene_on_close)

    if main_scene_load(self) == false {
        log.errorf("Main_Scene: Unable to load\n")

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
    pax.registry_read_many(&self.image_reg, []string {
        "data/main_scene/image/tiles.png",
        "data/main_scene/image/chars.png",
    }) or_return

    pax.registry_read_many(&self.sprite_reg, []string {
        "data/main_scene/sprite/tiles.json",
        "data/main_scene/sprite/chars.json",
    }) or_return

    pax.registry_read_many(&self.grid_reg, []string {
        "data/main_scene/grid/grid1.json",
        "data/main_scene/grid/grid2.json",
    }) or_return

    player := pax.group_find(&self.player_group, self.player) or_return

    player.visual.sprite = 2
    player.visual.chain  = 5

    player.transform.pivot = {48, 48}
    player.transform.scale = { 1,  1}

    player.motion.point = {48, 48}
    player.motion.speed = 128
    player.motion.grid  = 1

    player.camera = &self.camera

    grid := pax.registry_find(&self.grid_reg, player.motion.grid) or_return

    self.camera.size   = WINDOW_SIZE
    self.camera.scale  = {4, 4}

    self.camera.offset = [2]f32 {
        WINDOW_SIZE.x / 2 - f32(grid.tile.x / 2),
        WINDOW_SIZE.y / 2 - f32(grid.tile.y / 2),
    }

    self.camera.bounds = [4]f32 {
        0, 0,
        f32(grid.tile.x * grid.size.x),
        f32(grid.tile.y * grid.tile.y),
    }

    value := pax.grid_find_value(grid, 1, 3,
        pax.point_to_cell(grid, player.transform.pivot)) or_return

    value^ = self.player

    pax.window_resize(self.window, WINDOW_SIZE * self.camera.scale)

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

        pax.render_stop_chain(&self.render, player.visual, false)

        grid := pax.registry_find(&self.grid_reg, player.motion.grid) or_continue

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
            angle = motion_test(&player.motion, &self.grid_reg, angle, 1, layer)

            if angle.x == 0 && angle.y == 0 {
                break
            }
        }

        gate := motion_gate(&player.motion, &self.grid_reg, 3, 1)

        if gate != nil {
            motion_change(&player.motion, &self.grid_reg, 1, 3, gate^)
        }

        if motion_step(&player.motion, &self.grid_reg, angle, delta) {
            motion_grid(&player.motion, &self.grid_reg, angle, 1, 3)
        }

        player.transform.pivot = player.motion.point

        if player.camera != nil {
            pax.camera_move(&self.camera, player.transform.pivot)
        }

        pax.render_update_chain(&self.render, player.visual, delta)
    }
}

main_scene_draw_sprite_layer :: proc(self: ^Main_Scene, layer: int, cell: [2]int) -> bool
{
    player := pax.group_find(&self.player_group, self.player)       or_return
    grid   := pax.registry_find(&self.grid_reg, player.motion.grid) or_return

    value := pax.grid_find_value(grid, 2, layer, cell) or_return
    point := pax.cell_to_point(grid, cell)

    visual := pax.Visual {
        sprite = 1,
        frame  = value^,
    }

    transf := pax.Transform {
        pivot = point,
        scale = {1, 1},
    }

    pax.render_draw_sprite_frame(&self.render, visual, transf)

    return true
}

main_scene_draw_player_layer :: proc(self: ^Main_Scene, layer: int, cell: [2]int) -> bool
{
    player := pax.group_find(&self.player_group, self.player)       or_return
    grid   := pax.registry_find(&self.grid_reg, player.motion.grid) or_return

    value := pax.grid_find_value(grid, 2, layer, cell) or_return
    point := pax.cell_to_point(grid, cell)

    actor := pax.group_find(&self.player_group, value^) or_return

    pax.render_draw_sprite_chain(&self.render, player.visual, player.transform)

    return false
}

main_scene_draw :: proc(self: ^Main_Scene)
{
    player, _ := pax.group_find(&self.player_group, self.player)

    if player == nil { return }

    grid, _ := pax.registry_find(&self.grid_reg, player.motion.grid)

    if grid == nil { return }

    sdl.RenderClear(auto_cast self.render.renderer)

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

    sdl.RenderPresent(auto_cast self.render.renderer)
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
