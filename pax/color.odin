package pax

//
// Functions
//

color_from_u32le :: proc(value: u32le) -> [4]u8
{
    return [4]u8 {
        0 = u32le_to_nth_u8(value, 3),
        1 = u32le_to_nth_u8(value, 2),
        2 = u32le_to_nth_u8(value, 1),
        3 = u32le_to_nth_u8(value, 0),
    }
}

color_to_u32le :: proc(value: [4]u8) -> u32le
{
    return u32le_from_nth_u8(value.x, 3) |
           u32le_from_nth_u8(value.y, 2) |
           u32le_from_nth_u8(value.z, 1) |
           u32le_from_nth_u8(value.w, 0)
}

color_from_vec4_f32 :: proc(value: [4]f32) -> [4]u8
{
    return [4]u8 {
        0 = u8(value.x * 255.0),
        1 = u8(value.y * 255.0),
        2 = u8(value.z * 255.0),
        3 = u8(value.w * 255.0),
    }
}

color_to_vec4_f32 :: proc(value: [4]u8) -> [4]f32
{
    return [4]f32 {
        0 = f32(value.x) / 255.0,
        1 = f32(value.y) / 255.0,
        2 = f32(value.z) / 255.0,
        3 = f32(value.w) / 255.0,
    }
}

u32le_to_nth_u8 :: proc(value: u32le, index: int) -> u8
{
    shift := u32le(index * 8)
    mask  := u32le(255) << shift

    return u8((value & mask) >> shift)
}

u32le_from_nth_u8 :: proc(value: u8, index: int) -> u32le
{
    return u32le(value) << u32le(index * 8)
}
