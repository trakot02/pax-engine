package pax

import mathl "core:math/linalg"

import gl "vendor:OpenGL"

//
// Variables
//

RENDER_BUFFER_SIZE :: 8192

//
// Definitions
//

Render_State :: struct
{
    white_texture: Texture,

    array:  int,
    buffer: int,
}

//
// Functions
//

render_init :: proc(allocator := context.allocator) -> (Render_State, bool)
{
    array  := u32 {}
    buffer := u32 {}

    gl.Enable(gl.BLEND)
    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

    gl.Enable(gl.DEPTH_TEST)

    gl.GenVertexArrays(1, &array)
    gl.BindVertexArray(array)

    gl.GenBuffers(1, &buffer)
    gl.BindBuffer(gl.ARRAY_BUFFER, buffer)

    gl.BufferData(gl.ARRAY_BUFFER, RENDER_BUFFER_SIZE,
        nil, gl.DYNAMIC_DRAW)

    builder := Texture_Builder {}
    pixel   := [4]u8 {255, 255, 255, 255}

    texture_set_bytes(&builder, &pixel[0])
    texture_set_dimension(&builder, {1, 1})
    texture_set_channels(&builder, 4)

    texture, state := texture_init(&builder)

    if state == false { return {}, false }

    return Render_State {
        white_texture = texture,
        array         = int(array),
        buffer        = int(buffer),
    }, true
}

render_destroy :: proc(self: ^Render_State)
{
    array  := u32(self.array)
    buffer := u32(self.buffer)

    texture_destroy(&self.white_texture)

    gl.DeleteBuffers(1, &buffer)
    gl.DeleteVertexArrays(1, &array)
}

render_set_clear_color :: proc(self: ^Render_State, color: [4]f32)
{
    gl.ClearColor(color.r, color.g,
        color.b, color.a)
}

render_clear :: proc(self: ^Render_State)
{
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

render_flush :: proc(self: ^Render_State)
{
    // empty...
}
