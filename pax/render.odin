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
    array:  int,
    buffer: int,
}

//
// Functions
//

render_init :: proc(allocator := context.allocator) -> Render_State 
{
    array  := u32 {}
    buffer := u32 {}

    gl.GenVertexArrays(1, &array)
    gl.BindVertexArray(array)

    gl.GenBuffers(1, &buffer)
    gl.BindBuffer(gl.ARRAY_BUFFER, buffer)

    gl.BufferData(gl.ARRAY_BUFFER, RENDER_BUFFER_SIZE,
        nil, gl.DYNAMIC_DRAW)

    return Render_State {
        array  = int(array),
        buffer = int(buffer),
    }
}

render_destroy :: proc(self: ^Render_State)
{
    array  := u32(self.array)
    buffer := u32(self.buffer)

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
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

render_flush :: proc(self: ^Render_State)
{
    // empty...
}
