package pax

import mathl "core:math/linalg"

//
// Definitions
//

View :: struct
{
    position:  [2]f32,
    scale:     [2]f32,
    pivot:     [2]f32,
    rotation:  f32,
    viewport:  [4]f32,
    dimension: [2]f32,
    bounds:    [4]f32,
}

//
// Functions
//

view_init :: proc() -> View
{
    return View {
        scale = {1, 1},
    }
}

view_set_position :: proc(self: ^View, position: [2]f32)
{
    self.position = position

    dim := self.bounds.zw - self.dimension
    min := self.bounds.xy + self.pivot
    max := self.bounds.xy + self.pivot + dim

    if self.bounds.z != 0 && self.bounds.w != 0 {
        self.position.x = clamp(self.position.x, min.x, max.x)
        self.position.y = clamp(self.position.y, min.y, max.y)
    }
}

view_set_scale :: proc(self: ^View, scale: [2]f32)
{
    self.scale = scale
}

view_set_pivot :: proc(self: ^View, pivot: [2]f32)
{
    self.pivot = pivot
}

view_set_rotation :: proc(self: ^View, rotation: f32)
{
    self.rotation = rotation
}

view_set_viewport :: proc(self: ^View, viewport: [4]f32)
{
    self.viewport = viewport
}

view_set_dimension :: proc(self: ^View, dimension: [2]f32)
{
    self.dimension = dimension

    dim := self.bounds.zw - self.dimension
    min := self.bounds.xy + self.pivot
    max := self.bounds.xy + self.pivot + dim

    if self.bounds.z != 0 && self.bounds.w != 0 {
        self.position.x = clamp(self.position.x, min.x, max.x)
        self.position.y = clamp(self.position.y, min.y, max.y)
    }
}

view_set_rect :: proc(self: ^View, rect: [4]f32)
{
    view_set_position(self, rect.xy)
    view_set_dimension(self, rect.zw)
}

view_set_bounds :: proc(self: ^View, bounds: [4]f32)
{
    self.bounds = bounds

    view_set_position(self, self.position)
    view_set_dimension(self, self.dimension)
}

view_get_mat4_f32 :: proc(self: ^View) -> matrix[4, 4]f32
{
    left   := self.viewport.x
    right  := self.viewport.x + self.viewport.z
    bottom := self.viewport.y + self.viewport.w
    top    := self.viewport.y

    trans := mathl.matrix_ortho3d_f32(left, right, bottom, top, 0, 100)

    trans *= mathl.matrix4_translate_f32({
        self.pivot.x, self.pivot.y, 0,
    })

    trans *= mathl.matrix4_rotate_f32(self.rotation, {0, 0, 1})

    trans *= mathl.matrix4_scale_f32({
        self.scale.x, self.scale.y, 0,
    })

    trans *= mathl.matrix4_translate_f32({
        0 - self.position.x, 0 - self.position.y, 0,
    })

    return trans
}

view_move_by :: proc(self: ^View, movement: [2]f32, delta: f32)
{
    view_set_position(self, self.position + movement * delta)
}
