package pax

import mathl "core:math/linalg"

import gl "vendor:OpenGL"

//
// Variables
//

TRIANGLE_MAX :: 1024

VERT_OF_TRIANGLE  :: 3
VERT_OF_RECTANGLE :: 4

SIZE_OF_VERTEX   :: size_of(Render_Vertex)

VERTEX_MAX :: TRIANGLE_MAX * VERT_OF_TRIANGLE
BUFFER_MAX :: VERTEX_MAX   * SIZE_OF_VERTEX

//
// Definitions
//

Render_Vertex :: struct
{
    position: [2]f32,
    color:    [4]f32,
}

Render_Triangle  :: [VERT_OF_TRIANGLE]Render_Vertex
Render_Rectangle :: [VERT_OF_RECTANGLE]Render_Vertex

Render_Batch :: struct
{
    array: [VERTEX_MAX]Render_Vertex,
    count: int,
}

Render_State :: struct
{
    array:  int,
    vertex: int,

    shader: ^Shader,

    ortho: matrix[4, 4]f32,

    batch: Render_Batch,
}

//
// Functions
//

render_init :: proc() -> Render_State
{
    value  := Render_State {}
    array  := u32 {}
    vertex := u32 {}

    gl.GenVertexArrays(1, &array)
    gl.GenBuffers(1, &vertex)

    gl.BindVertexArray(array)
    gl.BindBuffer(gl.ARRAY_BUFFER, vertex)

    gl.BufferData(gl.ARRAY_BUFFER, BUFFER_MAX, nil, gl.DYNAMIC_DRAW)

    gl.EnableVertexAttribArray(0)
    gl.EnableVertexAttribArray(1)

    gl.VertexAttribPointer(0, 2, gl.FLOAT, false, size_of(Render_Vertex),
        offset_of(Render_Vertex, position))

    gl.VertexAttribPointer(1, 4, gl.FLOAT, false, size_of(Render_Vertex),
        offset_of(Render_Vertex, color))

    gl.BindVertexArray(0)

    value.array  = int(array)
    value.vertex = int(vertex)

    return value
}

render_destroy :: proc(self: ^Render_State)
{
    array  := u32(self.array)
    vertex := u32(self.vertex)

    gl.DeleteBuffers(1, &vertex)
    gl.DeleteVertexArrays(1, &array)
}

render_set_shader :: proc(self: ^Render_State, shader: ^Shader)
{
    self.shader = shader
}

render_set_viewport :: proc(self: ^Render_State, viewport: [4]f32)
{
    gl.Viewport(i32(viewport.x), i32(viewport.y),
        i32(viewport.z), i32(viewport.w))

    self.ortho = mathl.matrix_ortho3d_f32(
        viewport.x, viewport.x + viewport.z,
        viewport.y, viewport.y + viewport.w,
        -1.0, 1.0)
}

render_set_m4f32 :: proc(self: ^Render_State, name: string, mat: matrix[4, 4]f32) -> bool
{
    if self.shader != nil {
        return shader_set_m4f32(self.shader, name, mat)
    }

    return false
}

render_clear_color :: proc(self: ^Render_State, color: [4]f32)
{
    gl.ClearColor(
        color.r, color.g,
        color.b, color.a)

    gl.Clear(gl.COLOR_BUFFER_BIT)
}

render_begin_batch :: proc(self: ^Render_State)
{
    self.batch.count = 0
}

render_end_batch :: proc(self: ^Render_State)
{
    bytes := self.batch.count * SIZE_OF_VERTEX

    shader_bind(self.shader)

    gl.BindVertexArray(u32(self.array))
    gl.BufferSubData(gl.ARRAY_BUFFER, 0, bytes, raw_data(&self.batch.array))

    gl.DrawArrays(gl.TRIANGLES, 0, i32(self.batch.count))
}

render_draw_triangle :: proc(self: ^Render_State, triangle: Render_Triangle)
{
    if self.batch.count + VERT_OF_TRIANGLE >= VERTEX_MAX {
        render_end_batch(self)
        render_begin_batch(self)
    }

    for vertex, index in triangle {
        self.batch.array[self.batch.count + index] = triangle[index]
    }

    self.batch.count += VERT_OF_TRIANGLE
}
