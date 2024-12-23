package pax

import "core:mem"
import "core:encoding/json"
import "core:os"
import "core:log"

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
}

Sprite_Chain_Flag :: enum
{
    STOP,
    LOOP,
}

//
//
//
Sprite_Chain_Flags :: bit_set[Sprite_Chain_Flag]

Sprite_Chain :: struct
{
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
    flags: Sprite_Chain_Flags,

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
    texture: int,

    //
    //
    //
    frames: []Sprite_Frame,

    //
    //
    //
    chains: []Sprite_Chain,
}

Sprite_Registry :: struct
{
    //
    //
    //
    allocator: mem.Allocator,

    //
    //
    //
    resource: Resource,

    //
    //
    //
    registry: Registry(Sprite),
}

//
//
//
@(private)
sprite_destroy :: proc(self: ^Sprite_Registry, value: ^Sprite)
{
    mem.free_all(self.allocator)
}

//
//
//
@(private)
sprite_read :: proc(self: ^Sprite_Registry, name: string) -> (Sprite, bool)
{
    alloc := context.temp_allocator
    value := Sprite {}

    data, succ := os.read_entire_file_from_filename(name, alloc)

    if succ == false {
        log.errorf("Sprite: Unable to open %q for reading",
            name)

        return {}, false
    }

    error := json.unmarshal(data, &value,
        json.DEFAULT_SPECIFICATION, self.allocator)

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
@(private)
sprite_write :: proc(self: ^Sprite_Registry, name: string, value: ^Sprite) -> bool
{
    return false
}

//
//
//
sprite_registry_init :: proc(self: ^Sprite_Registry, allocator := context.allocator)
{
    self.allocator = allocator

    resource_init(&self.resource, allocator)
    registry_init(&self.registry, allocator)
}

//
//
//
sprite_registry_destroy :: proc(self: ^Sprite_Registry)
{
    registry_destroy(&self.registry)
    resource_destroy(&self.resource)

    self.allocator = {}
}

//
//
//
sprite_registry_insert :: proc(self: ^Sprite_Registry, sprite: Sprite) -> (int, bool)
{
    resource, _ := resource_create(&self.resource)
    value, _    := registry_insert(&self.registry, resource, sprite)

    if value != nil {
        return resource, true
    }

    resource_delete(&self.resource, resource)

    return 0, false
}

//
//
//
sprite_registry_remove :: proc(self: ^Sprite_Registry, sprite: int) -> bool
{
    value := registry_remove(&self.registry, sprite) or_return

    sprite_destroy(self, value)

    return resource_delete(&self.resource, sprite)
}

//
//
//
sprite_registry_clear :: proc(self: ^Sprite_Registry)
{
    for &sprite in self.registry.values {
        sprite_destroy(self, &sprite)
    }

    registry_clear(&self.registry)
    resource_clear(&self.resource)
}

//
//
//
sprite_registry_find :: proc(self: ^Sprite_Registry, sprite: int) -> (^Sprite, bool)
{
    return registry_find(&self.registry, sprite)
}

//
//
//
sprite_registry_read :: proc(self: ^Sprite_Registry, name: string) -> bool
{
    value, state := sprite_read(self, name)

    switch state {
        case false:
            log.errorf("Sprite_Registry: Unable to read %q",
                name)

        case true:
            sprite_registry_insert(self, value) or_return
    }

    return state
}

//
//
//
sprite_find_chain :: proc(self: ^Sprite, chain: int) -> (^Sprite_Chain, bool)
{
    chain := chain - 1

    if 0 <= chain && chain < len(self.chains) {
        return &self.chains[chain], true
    }

    return nil, false
}

//
//
//
sprite_find_frame :: proc(self: ^Sprite, frame: int, chain: int = 0) -> (^Sprite_Frame, bool)
{
    chain := chain - 1
    frame := frame - 1

    if 0 <= chain && chain < len(self.chains) {
        temp := self.chains[chain]

        // todo (trakot02): handle edge case better...
        if temp.frame == 0 { temp.frame = 1 }

        if 0 < temp.frame && temp.frame <= len(temp.frames) {
            frame = temp.frames[temp.frame - 1] - 1
        }
    }

    if 0 <= frame && frame < len(self.frames) {
        return &self.frames[frame], true
    }

    return nil, false
}

sprite_update_chain :: proc(self: ^Sprite, chain: int, delta: f32) -> bool
{
    chain := sprite_find_chain(self, chain) or_return

    chain.timer += delta

    if chain.timer >= chain.delay {
        chain.timer -= chain.delay

        if chain.flags & {.STOP} == {} {
            chain.frame %= len(chain.frames)
            chain.frame += 1
        }
    }

    return true
}

sprite_stop_chain :: proc(self: ^Sprite, chain: int, stop: bool) -> bool
{
    chain := sprite_find_chain(self, chain) or_return

    switch stop {
        case false: chain.flags -= {.STOP}
        case true:  chain.flags += {.STOP}
    }

    return true
}
