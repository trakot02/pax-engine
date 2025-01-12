package pax

import "core:log"
import "core:time"

Loop_Conf :: struct
{
    //
    //
    //
    max_frame_rate: int,

    //
    //
    //
    max_frame_skip: int,

    //
    //
    //
    first_scene: int,
}

Stage :: struct
{
    //
    //
    //
    scenes: [dynamic]Scene,

    //
    //
    //
    self: rawptr,

    //
    //
    //
    proc_start: proc(self: rawptr) -> bool,

    //
    //
    //
    proc_stop: proc(self: rawptr),
}

STAGE :: Stage {
    proc_start = proc_stage_start,
    proc_stop  = proc_empty,
}

Scene :: struct
{
    //
    //
    //
    self: rawptr,

    //
    //
    //
    proc_start: proc(self: rawptr, stage: rawptr) -> bool,

    //
    //
    //
    proc_stop: proc(self: rawptr),

    //
    //
    //
    proc_enter: proc(self: rawptr),

    //
    //
    //
    proc_leave: proc(self: rawptr),

    //
    //
    //
    proc_frame: proc(self: rawptr),

    //
    //
    //
    proc_input: proc(self: rawptr) -> int,

    //
    //
    //
    proc_step: proc(self: rawptr, delta: f32),

    //
    //
    //
    proc_draw: proc(self: rawptr),
}

SCENE :: Scene {
    proc_start = proc_scene_start,
    proc_stop  = proc_empty,
    proc_enter = proc_empty,
    proc_leave = proc_empty,
    proc_frame = proc_empty,
    proc_input = proc_scene_input,
    proc_step  = proc_scene_step,
    proc_draw  = proc_empty,
}

Scene_Handle :: struct
{
    //
    //
    //
    number: int,

    //
    //
    //
    scene: ^Scene,
}

//
//
//
proc_empty :: proc(self: rawptr) {}

//
//
//
proc_stage_start :: proc(self: rawptr) -> bool
{
    return true
}

//
//
//
proc_scene_start :: proc(self: rawptr, stage: rawptr) -> bool
{
    return true
}

//
//
//
proc_scene_input :: proc(self: rawptr) -> int
{
    return 0
}

//
//
//
proc_scene_step :: proc(self: rawptr, delta: f32) {}

//
//
//
stage_init :: proc(self: ^Stage, allocator := context.allocator)
{
    self.scenes = make([dynamic]Scene, allocator)
}

//
//
//
stage_destroy :: proc(self: ^Stage)
{
    delete(self.scenes)

    self.scenes = {}
}

//
//
//
stage_find :: proc(self: ^Stage, number: int) -> Scene_Handle
{
    handle := Scene_Handle {}
    index  := number - 1

    if 0 <= index && index < len(self.scenes) {
        handle.number = number
        handle.scene  = &self.scenes[index]
    }

    return handle
}

//
//
//
stage_clear :: proc(self: ^Stage)
{
    clear(&self.scenes)
}

//
//
//
stage_create :: proc(self: ^Stage, scene: Scene) -> Scene_Handle
{
    index  := len(self.scenes)
    number := index + 1

    _, error := append(&self.scenes, scene)

    if error != nil {
        log.errorf("Stage: Unable to append scene %v",
            scene)

        return {}
    }

    return stage_find(self, number)
}

//
//
//
stage_delete :: proc(self: ^Stage, number: int)
{
    log.errorf("Stage: Not implemented yet")
}

//
//
//
stage_start :: proc(self: ^Stage) -> bool
{
    count := len(self.scenes)
    index := 0

    state := self.proc_start(self.self)

    if state == true {
        for i := 1; i <= count; i += 1 {
            state = scene_start(&self.scenes[i - 1], self)
            index = i

            if state == false {
                break
            }
        }
    }

    if state == false {
        for i := index; i > 0; i -= 1 {
            scene_stop(&self.scenes[i - 1])
        }
    }

    return state
}

//
//
//
stage_stop :: proc(self: ^Stage)
{
    for &scene in self.scenes {
        scene_stop(&scene)
    }

    self.proc_stop(self.self)
}

//
//
//
stage_loop :: proc(self: ^Stage, conf: Loop_Conf) -> bool
{
    stage_start(self) or_return

    handle := stage_find(self, conf.first_scene)

    if handle.number == 0 { return false }

    tick := time.Tick {}

    frame_rate: f32 = max(1, f32(conf.max_frame_rate))
    frame_time: f32 = 1.0 / frame_rate

    elaps: f32 = 0
    input: int = 0

    for skips := 0; input >= 0; skips = 0 {
        delta := time.duration_seconds(time.tick_lap_time(&tick))
        elaps += f32(delta)

        scene_frame(handle.scene)

        for frame_time < elaps && skips <= conf.max_frame_skip {
            scene_step(handle.scene, frame_time)

            elaps -= frame_time
            skips += 1
        }

        scene_draw(handle.scene)

        input = scene_input(handle.scene)

        if input > 0 {
            next := stage_find(self, input)

            if next.number != 0 {
                scene_leave(handle.scene)
                scene_enter(next.scene)

                handle = next
            }
        }
    }

    scene_leave(handle.scene)
    stage_stop(self)

    return true
}

//
//
//
scene_start :: proc(self: ^Scene, stage: ^Stage) -> bool
{
    return self.proc_start(self.self, stage.self)
}

//
//
//
scene_stop :: proc(self: ^Scene)
{
    self.proc_stop(self.self)
}

//
//
//
scene_enter :: proc(self: ^Scene)
{
    self.proc_enter(self.self)
}

//
//
//
scene_leave :: proc(self: ^Scene)
{
    self.proc_leave(self.self)
}

//
//
//
scene_frame :: proc(self: ^Scene)
{
    self.proc_frame(self.self)
}

//
//
//
scene_input :: proc(self: ^Scene) -> int
{
    return self.proc_input(self.self)
}

//
//
//
scene_step :: proc(self: ^Scene, delta: f32)
{
    self.proc_step(self.self, delta)
}

//
//
//
scene_draw :: proc(self: ^Scene)
{
    self.proc_draw(self.self)
}
