package pax

import "core:mem"
import "core:log"
import "core:encoding/json"
import "core:os"

Grid_Layer :: []int
Grid_Stack :: []int

Grid_Gate :: struct
{
    //
    //
    //
    grid: int,

    //
    //
    //
    cell: [2]int,

    //
    //
    //
    step: [2]int,
}

Grid :: struct
{
    //
    //
    //
    tile: [2]int,

    //
    //
    //
    size: [2]int,

    //
    //
    //
    layers: []Grid_Layer,

    //
    //
    //
    stacks: []Grid_Stack,

    //
    //
    //
    gates: []Grid_Gate,
}

Grid_Registry :: struct
{
    //
    //
    //
    allocator: mem.Allocator,

    values: [dynamic]Grid,
}

//
//
//
@(private)
grid_destroy :: proc(self: ^Grid_Registry, value: ^Grid)
{
    mem.free_all(self.allocator)
}

//
//
//
@(private)
grid_read :: proc(self: ^Grid_Registry, name: string) -> (Grid, bool)
{
    alloc := context.temp_allocator
    value := Grid {}

    data, succ := os.read_entire_file_from_filename(name, alloc)

    if succ == false {
        log.errorf("Grid: Unable to open %q for reading",
            name)

        return {}, false
    }

    error := json.unmarshal(data, &value,
        json.DEFAULT_SPECIFICATION, self.allocator)

    mem.free_all(alloc)

    switch type in error {
        case json.Error: log.errorf("Grid: Unable to parse JSON")

        case json.Unmarshal_Data_Error: {
            switch type {
                case .Invalid_Data:          log.errorf("Grid: Unable to unmarshal JSON, Invalid data")
                case .Invalid_Parameter:     log.errorf("Grid: Unable to unmarshal JSON, Invalid parameter")
                case .Multiple_Use_Field:    log.errorf("Grid: Unable to unmarshal JSON, Multiple use field")
                case .Non_Pointer_Parameter: log.errorf("Grid: Unable to unmarshal JSON, Non pointer parameter")
                case:                        log.errorf("Grid: Unable to unmarshal JSON")
            }
        }

        case json.Unsupported_Type_Error: {
            log.errorf("Grid: Unable to parse JSON, Unsupported type")
        }
    }

    if error != nil { return {}, false }

    return value, true
}

//
// todo (trakot02): In the future...
//
@(private)
grid_write :: proc(self: ^Grid_Registry, name: string, value: ^Grid) -> bool
{
    return false
}

//
//
//
grid_registry_init :: proc(self: ^Grid_Registry, allocator := context.allocator)
{
    self.allocator = allocator
    self.values    = make([dynamic]Grid, allocator)
}

//
//
//
grid_registry_destroy :: proc(self: ^Grid_Registry)
{
    delete(self.values)

    self.values    = {}
    self.allocator = {}
}

//
//
//
grid_registry_insert :: proc(self: ^Grid_Registry, grid: Grid) -> (int, bool)
{
    index, error := append(&self.values, grid)

    if error != nil {
        log.errorf("Grid_Registry: Unable to insert %v",
            grid)

        return 0, false
    }

    return index + 1, true
}

//
//
//
grid_registry_remove :: proc(self: ^Grid_Registry, grid: int)
{
    log.errorf("Grid_Registry: Not implemented yet")
}

//
//
//
grid_registry_clear :: proc(self: ^Grid_Registry)
{
    for &grid in self.values {
        grid_destroy(self, &grid)
    }

    clear(&self.values)
}

//
//
//
grid_registry_find :: proc(self: ^Grid_Registry, grid: int) -> (^Grid, bool)
{
    grid := grid - 1

    if 0 <= grid && grid < len(self.values) {
        return &self.values[grid], true
    }

    return nil, false
}

//
//
//
grid_registry_read :: proc(self: ^Grid_Registry, name: string) -> bool
{
    value, state := grid_read(self, name)

    switch state {
        case false:
            log.errorf("Grid_Registry: Unable to read %q",
                name)

        case true:
            grid_registry_insert(self, value) or_return
    }

    return state
}

//
//
//
grid_find_layer :: proc(self: ^Grid, stack: int, layer: int) -> (^Grid_Layer, bool)
{
    stack_count := len(self.stacks)
    stack_index := stack - 1
    layer_index := layer - 1

    if 0 <= stack_index && stack_index < stack_count {
        stack       := &self.stacks[stack_index]
        layer_count := len(stack)

        if 0 <= layer_index && layer_index < layer_count {
            value := stack[layer_index] - 1

            if 0 <= value && value < len(self.layers) {
                return &self.layers[value], true
            }
        }
    }

    return nil, false
}

//
//
//
grid_find_value :: proc(self: ^Grid, stack: int, layer: int, cell: [2]int) -> (^int, bool)
{
    index := cell_to_index(self, cell)

    if cell.x < 0 || cell.x >= self.size.x ||
       cell.y < 0 || cell.y >= self.size.y { return nil, false }

    layer, _ := grid_find_layer(self, stack, layer)

    if layer != nil && index < len(layer) {
        return &layer[index], true
    }

    return nil, false
}

grid_find :: proc {
    grid_find_layer,
    grid_find_value,
}

//
//
//
cell_to_point :: proc(self: ^Grid, cell: [2]int) -> [2]f32
{
    return [2]f32 {
        f32(cell.x * self.tile.x),
        f32(cell.y * self.tile.y),
    }
}

//
//
//
cell_to_index :: proc(self: ^Grid, cell: [2]int) -> int
{
    return cell.y * self.size.x + cell.x
}

//
//
//
point_to_cell :: proc(self: ^Grid, point: [2]f32) -> [2]int
{
    return [2]int {
        int(point.x) / self.tile.x,
        int(point.y) / self.tile.y,
    }
}

//
//
//
index_to_cell :: proc(self: ^Grid, index: int) -> [2]int
{
    return {index % self.size.x, index / self.size.x}
}
