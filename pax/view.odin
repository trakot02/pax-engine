package pax

import mathl "core:math/linalg"

//
// Variables
//

VIEW := View { scale = {1, 1} }

//
// Definitions
//

View :: struct
{
    viewport:  [4]f32,
    position:  [2]f32,
    dimension: [2]f32,
    offset:    [2]f32,
    scale:     [2]f32,
    bounds:    [4]f32,
}

//
// Functions
//

view_set_viewport :: proc(self: ^View, viewport: [4]f32)
{
    self.viewport = viewport
}

view_set_position :: proc(self: ^View, position: [2]f32)
{
    dim := self.bounds.zw - self.dimension
    min := self.bounds.xy + self.offset
    max := self.bounds.xy + self.offset + dim

    self.position.x = clamp(position.x, min.x, max.x)
    self.position.y = clamp(position.y, min.y, max.y)
}

view_set_dimension :: proc(self: ^View, dimension: [2]f32)
{
    self.dimension = dimension
}

view_set_offset :: proc(self: ^View, offset: [2]f32)
{
    self.offset = offset
}

view_set_scale :: proc(self: ^View, scale: [2]f32)
{
    self.scale = scale
}

view_set_bounds :: proc(self: ^View, bounds: [4]f32)
{
    self.bounds = bounds

    view_set_position(self, self.position)
}

view_get_mat4_f32 :: proc(self: ^View) -> matrix[4, 4]f32
{
    trans := mathl.MATRIX4F32_IDENTITY

    left   := self.viewport.x
    right  := self.viewport.x + self.viewport.z
    bottom := self.viewport.y + self.viewport.w
    top    := self.viewport.y

    trans *= mathl.matrix_ortho3d_f32(left, right, bottom, top, 0, 100)

    trans *= mathl.matrix4_scale_f32({
        self.scale.x, self.scale.y, 0
    })

    trans *= mathl.matrix4_translate_f32({
        self.offset.x - self.position.x,
        self.offset.y - self.position.y,
        0,
    })

    return trans
}

view_move_by :: proc(self: ^View, movement: [2]f32, delta: f32)
{
    view_set_position(self, self.position + movement * delta)
}
