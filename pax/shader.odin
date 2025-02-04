package pax

import "core:log"
import "core:strings"
import "core:mem"

import gl "vendor:OpenGL"

//
// Definitions
//

Shader :: struct
{
    ident: int,
}

Shader_Builder :: struct
{
    vertex:   int,
    geometry: int,
    fragment: int,
}

//
// Functions
//

shader_vertex :: proc(self: ^Shader_Builder, vertex: string) -> bool
{
    clone, error := strings.clone_to_cstring(vertex,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader_Builder: Unable to clone vertex to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    ident := gl.CreateShader(gl.VERTEX_SHADER)

    gl.ShaderSource(ident, 1, &clone, nil)
    gl.CompileShader(ident)

    if shader_get_compile_error_for(self, int(ident)) == false {
        self.vertex = int(ident)
    }

    return true
}

shader_geometry :: proc(self: ^Shader_Builder, geometry: string) -> bool
{
    clone, error := strings.clone_to_cstring(geometry,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader_Builder: Unable to clone geometry to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    ident := gl.CreateShader(gl.GEOMETRY_SHADER)

    gl.ShaderSource(ident, 1, &clone, nil)
    gl.CompileShader(ident)

    if shader_get_compile_error_for(self, int(ident)) == false {
        self.geometry = int(ident)
    }

    return true
}

shader_fragment :: proc(self: ^Shader_Builder, fragment: string) -> bool
{
    clone, error := strings.clone_to_cstring(fragment,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader_Builder: Unable to clone fragment to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    ident := gl.CreateShader(gl.FRAGMENT_SHADER)

    gl.ShaderSource(ident, 1, &clone, nil)
    gl.CompileShader(ident)

    if shader_get_compile_error_for(self, int(ident)) == false {
        self.fragment = int(ident)
    }

    return true
}

shader_init :: proc(self: ^Shader_Builder) -> (Shader, bool)
{
    ident := gl.CreateProgram()

    if self.vertex   != 0 { gl.AttachShader(ident, u32(self.vertex))   }
    if self.geometry != 0 { gl.AttachShader(ident, u32(self.geometry)) }
    if self.fragment != 0 { gl.AttachShader(ident, u32(self.fragment)) }

    gl.LinkProgram(ident)

    if shader_get_link_error_for(self, int(ident)) == false {
        if self.vertex   != 0 { gl.DeleteShader(u32(self.vertex))   }
        if self.geometry != 0 { gl.DeleteShader(u32(self.geometry)) }
        if self.fragment != 0 { gl.DeleteShader(u32(self.fragment)) }

        self^ = {}

        return Shader { ident = int(ident) }, true
    }

    return {}, false
}

shader_destroy :: proc(self: ^Shader)
{
    gl.DeleteProgram(u32(self.ident))

    self.ident = 0
}

shader_bind :: proc(self: ^Shader)
{
    gl.UseProgram(u32(self.ident))
}

shader_unbind :: proc(self: ^Shader)
{
    gl.UseProgram(0)
}

shader_set_i32 :: proc(self: ^Shader, name: string, val: i32) -> bool
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    loc := gl.GetUniformLocation(u32(self.ident), clone)

    if loc != -1 {
        gl.Uniform1i(loc, val)
    }

    return loc != -1
}

shader_set_f32 :: proc(self: ^Shader, name: string, val: f32) -> bool
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    loc := gl.GetUniformLocation(u32(self.ident), clone)

    if loc != -1 {
        gl.Uniform1f(loc, val)
    }

    return loc != -1
}

shader_set_vec2_f32 :: proc(self: ^Shader, name: string, vec: [2]f32) -> bool
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    loc := gl.GetUniformLocation(u32(self.ident), clone)

    if loc != -1 {
        gl.Uniform2f(loc, vec.x, vec.y)
    }

    return loc != -1
}

shader_set_vec3_f32 :: proc(self: ^Shader, name: string, vec: [3]f32) -> bool
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    loc := gl.GetUniformLocation(u32(self.ident), clone)

    if loc != -1 {
        gl.Uniform3f(loc, vec.x, vec.y, vec.z)
    }

    return loc != -1
}

shader_set_vec4_f32 :: proc(self: ^Shader, name: string, vec: [4]f32) -> bool
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    loc := gl.GetUniformLocation(u32(self.ident), clone)

    if loc != -1 {
        gl.Uniform4f(loc, vec.x, vec.y, vec.z, vec.w)
    }

    return loc != -1
}

shader_set_mat4_f32 :: proc(self: ^Shader, name: string, mat: matrix[4, 4]f32) -> bool
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    loc := gl.GetUniformLocation(u32(self.ident), clone)
    arg := mat

    if loc != -1 {
        gl.UniformMatrix4fv(loc, 1, false, raw_data(&arg))
    }

    return loc != -1
}

shader_get_compile_error_for :: proc(self: ^Shader_Builder, ident: int) -> bool
{
    buffer := [1024]byte {}
    status := i32(0)

    gl.GetShaderiv(u32(ident), gl.COMPILE_STATUS, &status)

    if status == 0 {
        gl.GetShaderInfoLog(u32(ident), len(buffer), nil, &buffer[0])

        log.errorf("Shader_Builder: ERROR = %v", cstring(&buffer[0]))
    }

    return status == 0
}

shader_get_link_error_for :: proc(self: ^Shader_Builder, ident: int) -> bool
{
    buffer := [1024]byte {}
    status := i32(0)

    gl.GetProgramiv(u32(ident), gl.LINK_STATUS, &status)

    if status == 0 {
        gl.GetProgramInfoLog(u32(ident), len(buffer), nil, &buffer[0])

        log.errorf("Shader_Builder: ERROR = %v", cstring(&buffer[0]))
    }

    return status == 0
}
