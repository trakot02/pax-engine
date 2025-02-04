package pax

import mathl "core:math/linalg"

View :: struct
{
    // Viewport used to paint.
    viewport: [4]f32,

    // Current position of the view inside the world.
    position: [2]f32,

    // If "target" doesn't equal position the view should reach it, possibly with easing functions.
    target: [2]f32,

    // Distance between the content's and view's positions in the world.
    origin: [2]f32,

    // Bounds in world space where the view's position is enclosed.
    bounds: [4]f32,
}

view_set_viewport :: proc(self: ^View, viewport: [4]f32)
{
    self.viewport = viewport
}

view_set_position :: proc(self: ^View, position: [2]f32)
{
    self.position = position
}

view_set_target :: proc(self: ^View, target: [2]f32)
{
    self.target = target
}

view_set_origin :: proc(self: ^View, origin: [2]f32)
{
    self.origin = origin
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

    value *= mathl.matrix_ortho3d_f32(left, right, bottom, top, -100, 100)

    value *= mathl.matrix4_translate_f32({
        self.origin.x - self.position.x,
        self.origin.y - self.position.y,
        0,
    })

    return value
}
