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
    slot: int,
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

get_shader_compile_error_for :: proc(self: ^Shader_Builder, slot: int) -> bool
{
    buffer := [1024]byte {}
    status := i32(0)

    gl.GetShaderiv(u32(slot), gl.COMPILE_STATUS, &status)

    if status == 0 {
        gl.GetShaderInfoLog(u32(slot), len(buffer), nil, &buffer[0])

        log.errorf("Shader_Builder: ERROR = %v", cstring(&buffer[0]))
    }

    return status == 0
}

get_shader_link_error_for :: proc(self: ^Shader_Builder, slot: int) -> bool
{
    buffer := [1024]byte {}
    status := i32(0)

    gl.GetProgramiv(u32(slot), gl.LINK_STATUS, &status)

    if status == 0 {
        gl.GetProgramInfoLog(u32(slot), len(buffer), nil, &buffer[0])

        log.errorf("Shader_Builder: ERROR = %v", cstring(&buffer[0]))
    }

    return status == 0
}

shader_vertex :: proc(self: ^Shader_Builder, vertex: string) -> bool
{
    clone, error := strings.clone_to_cstring(vertex,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader_Builder: Unable to clone vertex to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    slot := gl.CreateShader(gl.VERTEX_SHADER)

    gl.ShaderSource(slot, 1, &clone, nil)
    gl.CompileShader(slot)

    if get_shader_compile_error_for(self, int(slot)) == false {
        self.vertex = int(slot)
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

    slot := gl.CreateShader(gl.GEOMETRY_SHADER)

    gl.ShaderSource(slot, 1, &clone, nil)
    gl.CompileShader(slot)

    if get_shader_compile_error_for(self, int(slot)) == false {
        self.geometry = int(slot)
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

    slot := gl.CreateShader(gl.FRAGMENT_SHADER)

    gl.ShaderSource(slot, 1, &clone, nil)
    gl.CompileShader(slot)

    if get_shader_compile_error_for(self, int(slot)) == false {
        self.fragment = int(slot)
    }

    return true
}

shader_init :: proc(self: ^Shader_Builder) -> (Shader, bool)
{
    slot := gl.CreateProgram()

    if self.vertex   != 0 { gl.AttachShader(slot, u32(self.vertex))   }
    if self.geometry != 0 { gl.AttachShader(slot, u32(self.geometry)) }
    if self.fragment != 0 { gl.AttachShader(slot, u32(self.fragment)) }

    gl.LinkProgram(slot)

    if get_shader_link_error_for(self, int(slot)) == false {
        if self.vertex   != 0 { gl.DeleteShader(u32(self.vertex))   }
        if self.geometry != 0 { gl.DeleteShader(u32(self.geometry)) }
        if self.fragment != 0 { gl.DeleteShader(u32(self.fragment)) }

        self^ = {}

        return Shader { slot = int(slot) }, true
    }

    return {}, false
}

shader_destroy :: proc(self: ^Shader)
{
    gl.DeleteProgram(u32(self.slot))

    self.slot = 0
}

shader_bind :: proc(self: ^Shader)
{
    gl.UseProgram(u32(self.slot))
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

    loc := gl.GetUniformLocation(u32(self.slot), clone)

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

    loc := gl.GetUniformLocation(u32(self.slot), clone)

    if loc != -1 {
        gl.Uniform1f(loc, val)
    }

    return loc != -1
}

shader_set_v2f32 :: proc(self: ^Shader, name: string, vec: [2]f32) -> bool
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    loc := gl.GetUniformLocation(u32(self.slot), clone)

    if loc != -1 {
        gl.Uniform2f(loc, vec.x, vec.y)
    }

    return loc != -1
}

shader_set_v3f32 :: proc(self: ^Shader, name: string, vec: [3]f32) -> bool
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    loc := gl.GetUniformLocation(u32(self.slot), clone)

    if loc != -1 {
        gl.Uniform3f(loc, vec.x, vec.y, vec.z)
    }

    return loc != -1
}

shader_set_v4f32 :: proc(self: ^Shader, name: string, vec: [4]f32) -> bool
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    loc := gl.GetUniformLocation(u32(self.slot), clone)

    if loc != -1 {
        gl.Uniform4f(loc, vec.x, vec.y, vec.z, vec.w)
    }

    return loc != -1
}

shader_set_m4f32 :: proc(self: ^Shader, name: string, mat: matrix[4, 4]f32) -> bool
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    loc := gl.GetUniformLocation(u32(self.slot), clone)
    arg := mat

    if loc != -1 {
        gl.UniformMatrix4fv(loc, 1, false, raw_data(&arg))
    }

    return loc != -1
}
