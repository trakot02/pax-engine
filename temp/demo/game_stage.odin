package demo

import "core:log"

import rl "vendor:raylib"

import "../pax"

WINDOW_SIZE  :: [2]f32 {320, 180}

Game_Stage :: struct {}

game_stage_start :: proc(self: ^Game_Stage) -> bool
{
    rl.InitWindow(320, 180, "Prova")
    rl.SetWindowState({.WINDOW_RESIZABLE})

    rl.SetExitKey(nil)

    return true
}

game_stage_stop :: proc(self: ^Game_Stage)
{
    rl.CloseWindow()
}

game_stage :: proc(self: ^Game_Stage) -> pax.Stage
{
    value := pax.Stage {}

    value.instance = auto_cast self

    value.proc_start = auto_cast game_stage_start
    value.proc_stop  = auto_cast game_stage_stop

    return value
}
