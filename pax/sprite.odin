package pax

import "core:mem"
import "core:log"
import "core:os"
import "core:encoding/json"

Sprite_Frame :: struct
{
    //
    //
    //
    rect: [4]int,

    //
    //
    //
    base: [2]f32,

    //
    //
    //
    delay: f32,
}

Sprite_Chain :: struct
{
    //
    //
    //
    loop: bool,

    //
    //
    //
    stop: bool,

    //
    //
    //
    frame: int,

    //
    //
    //
    delay: f32,

    //
    //
    //
    timer: f32,

    //
    //
    //
    frames: []int,
}

Sprite :: struct
{
    //
    //
    //
    image: int,

    //
    //
    //
    frames: []Sprite_Frame,

    //
    //
    //
    chains: []Sprite_Chain,
}

//
//
//
sprite_chain :: proc(self: ^Sprite, chain: int) -> (^Sprite_Chain, bool)
{
    count := len(self.chains)
    index := chain - 1

    if 0 <= index && index < count {
        return &self.chains[index], true
    }

    return nil, false
}

//
//
//
sprite_frame :: proc(self: ^Sprite, frame: int) -> (^Sprite_Frame, bool)
{
    count := len(self.frames)
    index := frame - 1

    if 0 <= index && index < count {
        return &self.frames[index], true
    }

    return nil, false
}

sprite_chain_update :: proc(self: ^Sprite, chain: int, delta: f32) -> bool
{
    chain := sprite_chain(self, chain) or_return

    chain.timer += delta

    if chain.timer >= chain.delay {
        chain.timer -= chain.delay

        if chain.stop == false {
            chain.frame %= len(chain.frames)
            chain.frame += 1
        }
    }

    return true
}

sprite_chain_stop :: proc(self: ^Sprite, chain: int, stop: bool) -> bool
{
    chain := sprite_chain(self, chain) or_return

    chain.stop = stop

    return true
}

Sprite_Context :: struct
{
    //
    //
    //
    allocator: mem.Allocator,
}

//
//
//
sprite_clear :: proc(self: ^Sprite_Context, value: ^Sprite)
{
    mem.free_all(self.allocator)
}

//
//
//
sprite_read :: proc(self: ^Sprite_Context, name: string) -> (Sprite, bool)
{
    spec  := json.DEFAULT_SPECIFICATION
    alloc := context.temp_allocator
    value := Sprite {}

    data, succ := os.read_entire_file_from_filename(name, alloc)

    if succ == false {
        log.errorf("Sprite: Unable to open %q for reading",
            name)

        return {}, false
    }

    error := json.unmarshal(data, &value, spec, self.allocator)

    mem.free_all(alloc)

    switch type in error {
        case json.Error: log.errorf("Sprite: Unable to parse JSON")

        case json.Unmarshal_Data_Error: {
            switch type {
                case .Invalid_Data:          log.errorf("Sprite: Unable to unmarshal JSON, Invalid data")
                case .Invalid_Parameter:     log.errorf("Sprite: Unable to unmarshal JSON, Invalid parameter")
                case .Multiple_Use_Field:    log.errorf("Sprite: Unable to unmarshal JSON, Multiple use field")
                case .Non_Pointer_Parameter: log.errorf("Sprite: Unable to unmarshal JSON, Non pointer parameter")
                case:                        log.errorf("Sprite: Unable to unmarshal JSON")
            }
        }

        case json.Unsupported_Type_Error: {
            log.errorf("Sprite: Unable to parse JSON, Unsupported type")
        }
    }

    if error != nil { return {}, false }

    return value, true
}

//
// todo (trakot02): In the future...
//
// sprite_write :: proc(self: ^Sprite_Context, name: string, value: ^Sprite) -> bool
// {
//     return false
// }

//
//
//
sprite_registry :: proc(self: ^Sprite_Context) -> Registry(Sprite)
{
    value := Registry(Sprite) {}

    value.instance   = auto_cast self
    value.clear_proc = auto_cast sprite_clear
    value.read_proc  = auto_cast sprite_read
    // value.write_proc = auto_cast sprite_write

    return value
}
