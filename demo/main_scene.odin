package demo

import "core:log"

import sdl  "vendor:sdl2"
import sdli "vendor:sdl2/image"

import "../pax"

Main_Scene :: struct
{
    window: ^pax.Window,
    render: pax.Render_State,
    grid:   pax.Grid_State,

    camera: pax.Camera,

    keyboard: pax.Keyboard,

    image_reader:  pax.Image_Reader,
    sprite_reader: pax.Sprite_Reader,
    grid_reader:   pax.Grid_Reader,

    world:        pax.World,
    player_group: pax.Group(Player),

    player: int,

    state: int,
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
    }
}

main_scene_on_close :: proc(self: ^Main_Scene)
{
    self.state = -1
}

main_scene_start :: proc(self: ^Main_Scene, stage: ^Game_Stage) -> bool
{
    self.window = &stage.window

    pax.keyboard_init(&self.keyboard)
    pax.render_init(&self.render)
    pax.grid_init(&self.grid)
    pax.world_init(&self.world)
    pax.group_init(&self.player_group)

    self.player = pax.world_create_actor(&self.world)

    if self.player < 0 { return false }

    player := pax.group_insert(&self.player_group, self.player)

    if player == nil { return false }

    self.render.renderer = sdl.CreateRenderer(self.window.raw, -1, {.ACCELERATED})
    self.render.camera   = &self.camera

    if self.render.renderer == nil {
        log.errorf("SDL: %v\n", sdl.GetErrorString())

        return false
    }

    self.image_reader.renderer   = self.render.renderer
    self.sprite_reader.allocator = context.allocator
    self.grid_reader.allocator   = context.allocator

    pax.signal_insert(&self.keyboard.key_release, self,         main_scene_on_key_release)
    pax.signal_insert(&self.keyboard.key_release, player,       player_on_key_release)
    pax.signal_insert(&self.keyboard.key_press,   player,       player_on_key_press)
    pax.signal_insert(&self.keyboard.key_press,   &self.camera, pax.camera_on_key_press)
    pax.signal_insert(&self.window.close,         self,         main_scene_on_close)

    if main_scene_load(self) == false { return false }

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

    sheets := [?]string {
        "data/main_scene/sprite/tiles.json",
        "data/main_scene/sprite/chars.json",
    }

    grids := [?]string {
        "data/main_scene/grid/grid1.json",
        "data/main_scene/grid/grid2.json",
    }

    for name in images {
        image, succ := pax.image_read(&self.image_reader, name)

        if succ == false { return false }

        _, error := append(&self.render.images, image)

        if error != nil {
            log.errorf("Unable to load image %q\n", name)

            return false
        }
    }

    for name in sheets {
        sheet, succ := pax.sprite_read(&self.sprite_reader, name)

        if succ == false { return false }

        _, error := append(&self.render.sprites, sheet)

        if error != nil {
            log.errorf("Unable to load image %q\n", name)

            return false
        }
    }

    for name in grids {
        grid, succ := pax.grid_read(&self.grid_reader, name)

        if succ == false { return false }

        _, error := append(&self.grid.grids, grid)

        if error != nil {
            log.errorf("Unable to load grid %q\n", name)

            return false
        }
    }

    player := pax.group_find(&self.player_group, self.player)

    player.visible.sprite = 1
    player.visible.chain  = 4

    player.transform.point = {48, 48}

    player.motion.point = {48, 48}
    player.motion.speed = 128
    player.camera       = &self.camera

    grid := pax.grid_find(&self.grid, player.motion.grid)

    value := pax.grid_find_value(grid, 0, 3,
        pax.point_to_cell(grid, player.transform.point))

    if value == nil { return false }

    value^ = self.player

    self.camera.size   = WINDOW_SIZE
    self.camera.offset = WINDOW_SIZE / 2 - grid.tile / 2
    self.camera.scale  = {4, 4}

    pax.window_resize(self.window, [2]int {
        int(f32(WINDOW_SIZE.x) * self.camera.scale.x),
        int(f32(WINDOW_SIZE.y) * self.camera.scale.y),
    })

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

        pax.render_stop_chain(&self.render, player.visible, true)

        switch angle {
            case { 0, -1}: player.visible.chain = 8
            case { 1, -1}: player.visible.chain = 9
            case { 1,  0}: player.visible.chain = 10
            case { 1,  1}: player.visible.chain = 11
            case { 0,  1}: player.visible.chain = 12
            case {-1,  1}: player.visible.chain = 13
            case {-1,  0}: player.visible.chain = 14
            case {-1, -1}: player.visible.chain = 15
        }

        grid := pax.grid_find(&self.grid, player.motion.grid)

        for layer in 0 ..< len(grid.stacks[0]) {
            angle = motion_test(&player.motion, &self.grid, angle, 0, layer)
        }

        gate := motion_gate(&player.motion, &self.grid, 2, 0)

        if gate != nil {
            motion_change(&player.motion, &self.grid, 0, 3, gate^)
        }

        if motion_step(&player.motion, &self.grid, angle, delta) {
            motion_grid(&player.motion, &self.grid, angle, 0, 3)

            pax.render_stop_chain(&self.render, player.visible, false)
        }

        player.transform.point = {
            int(player.motion.point.x),
            int(player.motion.point.y),
        }

        if player.camera != nil {
            player.camera.follow = player.transform.point
        }

        player.visible.timer += delta

        pax.render_update_chain(&self.render, &player.visible)
    }
}

main_scene_draw_sprite_layer :: proc(self: ^Main_Scene, layer: int, cell: [2]int)
{
    grid := pax.grid_find(&self.grid,
        pax.group_find(&self.player_group, self.player).motion.grid)

    value := pax.grid_find_value(grid, 1, layer, cell)
    point := pax.cell_to_point(grid, cell)

    if value == nil { return }

    visibl := pax.Visible {
        sprite = 0,
        frame  = value^,
    }

    transf := pax.Transform {
        point = point,
    }

    pax.render_draw_sprite_frame(&self.render, visibl, transf)
}

main_scene_draw_player_layer :: proc(self: ^Main_Scene, layer: int, cell: [2]int)
{
    grid := pax.grid_find(&self.grid,
        pax.group_find(&self.player_group, self.player).motion.grid)

    value := pax.grid_find_value(grid, 1, layer, cell)
    point := pax.cell_to_point(grid, cell)

    if value == nil { return }

    player := pax.group_find(&self.player_group, value^)

    if player != nil {
        pax.render_draw_sprite_chain(&self.render, player.visible, player.transform)
    }
}

main_scene_draw :: proc(self: ^Main_Scene)
{
    grid := pax.grid_find(&self.grid,
        pax.group_find(&self.player_group, self.player).motion.grid)

    sdl.RenderClear(self.render.renderer)

    area := pax.camera_grid_area(&self.camera, grid)

    for row in area[0].y ..= area[1].y {
        for col in area[0].x ..= area[1].x {
            main_scene_draw_sprite_layer(self, 0, {col, row})
            main_scene_draw_sprite_layer(self, 1, {col, row})
        }
    }

    for row in area[0].y ..= area[1].y {
        for col in area[0].x ..= area[1].x {
            main_scene_draw_sprite_layer(self, 2, {col, row})
            main_scene_draw_player_layer(self, 3, {col, row})
        }
    }

    sdl.RenderPresent(self.render.renderer)
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
