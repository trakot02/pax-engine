package pax

import mathl "core:math/linalg"

Transform :: struct
{
    position: [2]f32,
    scale:    [2]f32,
    pivot:    [2]f32,
    rotation: f32,
}

transform_vec2_f32 :: proc(self: Transform, vec: [2]f32) -> [2]f32
{
    trans := mathl.matrix2_rotate_f32(self.rotation)
    value := vec

    value -= self.pivot
    value *= trans
    value += self.pivot

    value *= self.scale

    value += self.position

    return value
}
