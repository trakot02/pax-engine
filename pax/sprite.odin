package pax

import "core:mem"
import "core:log"
import "core:os"
import "core:encoding/json"

Sprite_Frame :: struct
{
    rect:  [4]int,
    base:  [2]int,
    delay: f32,
}

Sprite_Chain :: struct
{
    loop:   bool,
    stop:   bool,
    frame:  int,
    delay:  f32,
    frames: []int,
}

Sprite :: struct
{
    image: int,
    frames: []Sprite_Frame,
    chains: []Sprite_Chain,
}

Sprite_Reader :: struct
{
    allocator: mem.Allocator,
}

sprite_read :: proc(self: ^Sprite_Reader, name: string) -> (Sprite, bool)
{
    spec  := json.DEFAULT_SPECIFICATION
    temp  := context.temp_allocator
    value := Sprite {}

    data, succ := os.read_entire_file_from_filename(name, temp)

    if succ == false {
        log.errorf("Unable to open %q for reading\n",
            name)

        return {}, false
    }

    error := json.unmarshal(data, &value, spec, self.allocator)

    mem.free_all(temp)

    switch type in error {
        case json.Error: log.errorf("Unable to parse JSON\n")

        case json.Unmarshal_Data_Error: {
            log.errorf("Unable to unmarshal JSON:")

            switch type {
                case .Invalid_Data:          log.errorf("Invalid data\n")
                case .Invalid_Parameter:     log.errorf("Invalid parameter\n")
                case .Multiple_Use_Field:    log.errorf("Multiple use field\n")
                case .Non_Pointer_Parameter: log.errorf("Non pointer parameter\n")
                case:                        log.errorf("\n")
            }
        }

        case json.Unsupported_Type_Error: {
            log.errorf("Unable to parse JSON: Unsupported type\n")
        }
    }

    if error != nil {
        return {}, false
    }

    return value, true
}

sprite_clear :: proc(self: ^Sprite_Reader, value: ^Sprite)
{
    mem.free_all(self.allocator)
}
