package demo

import "core:math/linalg"

import "../pax"

Motion_State :: enum
{
    STILL, MOVING,
}

Motion :: struct
{
    point:  [2]f32,
    target: [2]f32,
    normal: [2]f32,
    grid:   int,
    speed:  f32,
    state:  Motion_State,
}

motion_step :: proc(self: ^Motion, registry: ^pax.Grid_Registry, step: [2]int, delta: f32) -> bool
{
    active := pax.grid_registry_find(registry, self.grid) or_return

    switch self.state {
        case .STILL: {
            tile := pax.cell_to_point(active, step)

            if step.x == 0 && step.y == 0 { return false }

            diff := [2]f32 {f32(tile.x), f32(tile.y)}

            self.target = self.point + diff
            self.normal = linalg.normalize(diff)
            self.state  = .MOVING

            return true
        }

        case .MOVING: {
            diff := self.target - self.point
            step := self.normal * self.speed * delta

            self.point += step

            if diff.x * diff.x <= step.x * step.x {
                self.point.x = self.target.x
            }

            if diff.y * diff.y <= step.y * step.y {
                self.point.y = self.target.y
            }

            if self.target == self.point {
                self.state  = .STILL
            }
        }
    }

    return false
}

motion_test :: proc(self: ^Motion, registry: ^pax.Grid_Registry, step: [2]int, stack: int, layer: int) -> [2]int
{
    active, _ := pax.grid_registry_find(registry, self.grid)
    step      := step

    if active == nil || (step.x == 0 && step.y == 0 ) {
        return step
    }

    cell      := pax.point_to_cell(active, self.point)
    next_x, _ := pax.grid_find_value(active, stack, layer, [2]int {cell.x + step.x, cell.y})
    next_y, _ := pax.grid_find_value(active, stack, layer, [2]int {cell.x, cell.y + step.y})

    if next_x == nil || next_x^ > 0 { step.x = 0 }
    if next_y == nil || next_y^ > 0 { step.y = 0 }

    if step.x == 0 && step.y == 0 { return step }

    next, _ := pax.grid_find_value(active, stack, layer, cell + step)

    if next == nil || next^ > 0 {
        step.x = 0
        step.y = 0
    }

    return step
}

motion_grid :: proc(self: ^Motion, registry: ^pax.Grid_Registry, step: [2]int, stack: int, layer: int)
{
    active, _ := pax.grid_registry_find(registry, self.grid)

    if active == nil { return }

    cell    := pax.point_to_cell(active, self.point)
    curr, _ := pax.grid_find_value(active, stack, layer, cell)
    next, _ := pax.grid_find_value(active, stack, layer, cell + step)

    if curr != nil && next != nil {
        next^ = curr^
        curr^ = 0
    }
}

motion_gate :: proc(self: ^Motion, registry: ^pax.Grid_Registry, stack: int, layer: int) -> ^pax.Grid_Gate
{
    active, _ := pax.grid_registry_find(registry, self.grid)

    if active == nil { return nil }

    cell    := pax.point_to_cell(active, self.point)
    curr, _ := pax.grid_find_value(active, stack, layer, cell)

    if curr != nil && curr^ > 0 {
        if curr^ <= len(active.gates) {
            return &active.gates[curr^ - 1]
        }
    }

    return nil
}

motion_change :: proc(self: ^Motion, registry: ^pax.Grid_Registry, stack: int, layer: int, gate: pax.Grid_Gate)
{
    active, _ := pax.grid_registry_find(registry, self.grid)
    dest, _   := pax.grid_registry_find(registry, gate.grid)

    if active == nil || dest == nil || self.state != .STILL { return }

    cell    := pax.point_to_cell(active, self.point)
    curr, _ := pax.grid_find_value(active, stack, layer, cell)
    next, _ := pax.grid_find_value(dest,   stack, layer, gate.cell + gate.step)

    point := pax.cell_to_point(dest, gate.cell)
    step  := pax.cell_to_point(dest, gate.step)

    if next != nil && curr != nil {
        self.point = [2]f32 {
            f32(point.x), f32(point.y),
        }

        self.target = self.point + [2]f32 {
            f32(step.x), f32(step.y),
        }

        if gate.step != {} {
            self.normal = linalg.normalize([2]f32 {
                f32(step.x), f32(step.y),
            })

            self.state = .MOVING
        }

        next^ = curr^
        curr^ = 0

        self.grid = gate.grid
    }
}
