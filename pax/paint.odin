package pax

import mathl "core:math/linalg"

import gl "vendor:OpenGL"

//
// Variables
//

PAINT_VERTEX_SIZE :: size_of(Paint_Vertex)

PAINTER_TRIANGLE_MAX :: 1024

PAINTER_VERTEX_MAX :: PAINTER_TRIANGLE_MAX * 3 
PAINTER_BUFFER_MAX :: PAINTER_VERTEX_MAX   * PAINT_VERTEX_SIZE

//
// Definitions
//

Paint_Vertex :: struct
{
    position: [2]f32,
    color:    [4]f32,
    texture:  [2]f32,
}

Painter_Batch :: struct
{
    texture: ^Texture,
    array:   [PAINTER_VERTEX_MAX]Paint_Vertex,
    count:   int,
}

Painter :: struct
{
    array:  int,
    vertex: int,

    batch: Painter_Batch,

    view:   ^View,
    shader: ^Shader,
}

//
// Functions
//

painter_init :: proc() -> Painter
{
    array  := u32 {}
    vertex := u32 {}

    gl.GenVertexArrays(1, &array)
    gl.GenBuffers(1, &vertex)

    gl.BindVertexArray(array)
    gl.BindBuffer(gl.ARRAY_BUFFER, vertex)

    gl.BufferData(gl.ARRAY_BUFFER, PAINTER_BUFFER_MAX, nil, gl.DYNAMIC_DRAW)

    gl.EnableVertexAttribArray(0)
    gl.EnableVertexAttribArray(1)
    gl.EnableVertexAttribArray(2)

    gl.VertexAttribPointer(0, 2, gl.FLOAT, false, size_of(Paint_Vertex),
        offset_of(Paint_Vertex, position))

    gl.VertexAttribPointer(1, 4, gl.FLOAT, false, size_of(Paint_Vertex),
        offset_of(Paint_Vertex, color))

    gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(Paint_Vertex),
        offset_of(Paint_Vertex, texture))

    gl.BindVertexArray(0)

    return Painter {
        array  = int(array),
        vertex = int(vertex),
    }
}

painter_destroy :: proc(self: ^Painter)
{
    array  := u32(self.array)
    vertex := u32(self.vertex)

    gl.DeleteBuffers(1, &vertex)
    gl.DeleteVertexArrays(1, &array)
}

painter_set_view :: proc(self: ^Painter, view: ^View)
{
    self.view = view
}

painter_set_shader :: proc(self: ^Painter, shader: ^Shader)
{
    self.shader = shader

    if self.shader != nil {
        shader_bind(self.shader)
    }
}

painter_set_mat4_f32 :: proc(self: ^Painter, name: string, mat: matrix[4, 4]f32) -> bool
{
    if self.shader != nil {
        return shader_set_mat4_f32(self.shader, name, mat)
    }

    return false
}

painter_clear_color :: proc(self: ^Painter, color: [4]f32)
{
    gl.ClearColor(
        color.r, color.g,
        color.b, color.a)

    gl.Clear(gl.COLOR_BUFFER_BIT)
}

painter_begin_batch :: proc(self: ^Painter)
{
    self.batch.count = 0
}

painter_end_batch :: proc(self: ^Painter)
{
    left   := i32(self.view.viewport.x)
    top    := i32(self.view.viewport.y)
    width  := i32(self.view.viewport.z)
    height := i32(self.view.viewport.w)

    bytes := self.batch.count * PAINT_VERTEX_SIZE 

    if self.batch.texture != nil {
        gl.BindTexture(gl.TEXTURE_2D, u32(self.batch.texture.ident))
    }

    if bytes != 0 {
        gl.BindVertexArray(u32(self.array))
        gl.BufferSubData(gl.ARRAY_BUFFER, 0, bytes, raw_data(&self.batch.array))

        gl.Viewport(left, top, width, height)
        gl.DrawArrays(gl.TRIANGLES, 0, i32(self.batch.count))
    }
}

painter_batch_poly3 :: proc(self: ^Painter, polygon: [3]Paint_Vertex, texture: ^Texture = nil)
{
    count := self.batch.count + 3 

    if count >= PAINTER_VERTEX_MAX {
        painter_end_batch(self)
        painter_begin_batch(self)
    }

    if self.batch.texture != texture {
        painter_end_batch(self)
        painter_begin_batch(self)

        self.batch.texture = texture
    }

    self.batch.array[self.batch.count + 0] = polygon[0]
    self.batch.array[self.batch.count + 1] = polygon[1]
    self.batch.array[self.batch.count + 2] = polygon[2]

    self.batch.count = count
}

painter_batch_poly4 :: proc(self: ^Painter, polygon: [4]Paint_Vertex, texture: ^Texture = nil)
{
    count := self.batch.count + 6 

    if count >= PAINTER_VERTEX_MAX {
        painter_end_batch(self)
        painter_begin_batch(self)
    }

    if self.batch.texture != texture {
        painter_end_batch(self)
        painter_begin_batch(self)

        self.batch.texture = texture
    }

    self.batch.array[self.batch.count + 0] = polygon[0]
    self.batch.array[self.batch.count + 1] = polygon[1]
    self.batch.array[self.batch.count + 2] = polygon[2]
    self.batch.array[self.batch.count + 3] = polygon[0]
    self.batch.array[self.batch.count + 4] = polygon[2]
    self.batch.array[self.batch.count + 5] = polygon[3]

    self.batch.count = count
}

paint_vertex_init :: proc(position: [2]f32, color: [4]u8, texture: [2]f32) -> Paint_Vertex
{
    return {
        position = position,
        color    = color_to_vec4_f32(color),
        texture  = {
            clamp(texture.x, 0, 1),
            clamp(texture.y, 0, 1),
        }
    }
}
