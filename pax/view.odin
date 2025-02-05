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
    // Viewport used to paint.
    viewport: [4]f32,

    // Current position of the view inside the world.
    position: [2]f32,

    dimension: [2]f32,

    // If "target" doesn't equal position the view should reach it, possibly with easing functions.
    target: [2]f32,

    // Distance between the content's and view's positions in the world.
    offset: [2]f32,

    scale: [2]f32,

    // Bounds in world space where the view's position is enclosed.
    bounds: [4]f32,
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
    self.position = position
}

view_set_dimension :: proc(self: ^View, dimension: [2]f32)
{
    self.dimension = dimension
}

view_set_target :: proc(self: ^View, target: [2]f32)
{
    self.target = target
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
}

view_get_matrix :: proc(self: ^View) -> matrix[4, 4]f32
{
    value := mathl.MATRIX4F32_IDENTITY

    left   := self.viewport.x
    right  := self.viewport.x + self.viewport.z
    bottom := self.viewport.y + self.viewport.w
    top    := self.viewport.y

    value *= mathl.matrix_ortho3d_f32(left, right, bottom, top, 0, 100)

    value *= mathl.matrix4_scale_f32({
        self.scale.x, self.scale.y, 0
    })

    value *= mathl.matrix4_translate_f32({
        self.offset.x - self.position.x,
        self.offset.y - self.position.y,
        0,
    })

    return value
}

view_move_to :: proc(self: ^View, position: [2]f32)
{
    dim := self.bounds.zw - self.dimension
    min := self.bounds.xy + self.offset
    max := self.bounds.xy + self.offset + dim 

    self.position.x = clamp(position.x, min.x, max.x)
    self.position.y = clamp(position.y, min.y, max.y)
}

view_move_by :: proc(self: ^View, movement: [2]f32)
{
    view_move_to(self, self.position + movement)
}
