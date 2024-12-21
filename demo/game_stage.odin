package demo

import "core:log"

import sdl  "vendor:sdl2"
import sdli "vendor:sdl2/image"

import "../pax"

WINDOW_SIZE  :: [2]f32 {320, 180}

Game_Stage :: struct
{
    window:   pax.Window,
    renderer: pax.Renderer,
}

game_stage_start :: proc(self: ^Game_Stage) -> bool
{
    if sdl.Init(sdl.INIT_VIDEO) != 0 {
        log.errorf("SDL: %v", sdl.GetErrorString())

        return false
    }

    if sdli.Init(sdli.INIT_PNG) != sdli.INIT_PNG {
        log.errorf("SDL: %v", sdl.GetErrorString())

        return false
    }

    pax.window_init(&self.window, WINDOW_SIZE)      or_return
    pax.renderer_init(&self.renderer, &self.window) or_return

    return true
}

game_stage_stop :: proc(self: ^Game_Stage)
{
    sdli.Quit()
    sdl.Quit()
}

game_stage :: proc(self: ^Game_Stage) -> pax.Stage
{
    value := pax.Stage {}

    value.instance = auto_cast self

    value.proc_start = auto_cast game_stage_start
    value.proc_stop  = auto_cast game_stage_stop

    return value
}
