package pax

Camera :: struct
{
    //
    //
    //
    size: [2]f32,

    //
    //
    //
    bounds: [4]f32,

    //
    //
    //
    follow: [2]f32,

    //
    //
    //
    offset: [2]f32,

    //
    //
    //
    scale: [2]f32,
}

//
//
//
camera_move :: proc(self: ^Camera, point: [2]f32)
{
    self := self

    self.follow.x = clamp(point.x,
        self.bounds.x + self.offset.x,
        self.bounds.z + self.offset.x - self.size.x)

    self.follow.y = clamp(point.y,
        self.bounds.y + self.offset.y,
        self.bounds.w + self.offset.y - self.size.y)
}

//
//
//
camera_point :: proc(self: ^Camera) -> [2]f32
{
    return self.offset - self.follow
}

//
//
//
camera_scale :: proc(self: ^Camera) -> [2]f32
{
    return self.scale
}

//
//
//
camera_grid_follow :: proc(self: ^Camera, grid: ^Grid) -> [2]int
{
    return point_to_cell(grid, self.follow)
}

//
//
//
camera_grid_area :: proc(self: ^Camera, grid: ^Grid) -> [2][2]int
{
    size := point_to_cell(grid, [2]f32 {
        f32(self.size.x), f32(self.size.y),
    }) + 1

    follow := point_to_cell(grid, self.follow)

    return {follow - size, follow + size}
}
