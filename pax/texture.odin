package pax

import "core:log"
import "core:strings"
import "core:mem"

import gl   "vendor:OpenGL"
import stbi "vendor:stb/image"

//
// Definitions
//

Texture :: struct
{
    ident:     int,
    dimension: [2]int,
    channels:  int,
}

Texture_Builder :: struct
{
    bytes:     [^]byte,
    dimension: [2]int,
    channels:  int,
}

//
// Functions
//

texture_set_bytes :: proc(self: ^Texture_Builder, bytes: [^]byte)
{
    self.bytes = bytes
}

texture_set_dimension :: proc(self: ^Texture_Builder, dimension: [2]int)
{
    self.dimension = dimension
}

texture_set_channels :: proc(self: ^Texture_Builder, channels: int)
{
    self.channels = channels
}

texture_init :: proc(self: ^Texture_Builder) -> (Texture, bool)
{
    ident    := u32(0)
    width    := i32(self.dimension.x)
    height   := i32(self.dimension.y)
    channels := self.channels

    gl.GenTextures(1, &ident)
    gl.BindTexture(gl.TEXTURE_2D, ident)

    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA,
        gl.UNSIGNED_BYTE, self.bytes)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)

    gl.BindTexture(gl.TEXTURE_2D, 0)

    self^ = {}

    return Texture {
        ident     = int(ident),
        dimension = {int(width), int(height)},
        channels  = channels,
    }, true
}

texture_read :: proc(name: string) -> (Texture, bool)
{
    builder := Texture_Builder {}

    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Texture_Builder: Unable to clone name to c-string")

        return {}, false
    }

    defer mem.free_all(context.temp_allocator)

    width    := i32(0)
    height   := i32(0)
    channels := i32(0)

    bytes := stbi.load(clone, &width, &height, &channels, 0)

    if bytes == nil {
        log.errorf("Texture_Builder: Unable to read texture from file")

        return {}, false
    }

    defer stbi.image_free(builder.bytes)

    builder.bytes     = bytes
    builder.dimension = {int(width), int(height)}
    builder.channels  = int(channels)

    return texture_init(&builder)
}

texture_destroy :: proc(self: ^Texture)
{
    ident := u32(self.ident)

    gl.DeleteTextures(1, &ident)

    self.ident = 0
}

texture_bind :: proc(self: ^Texture)
{
    gl.BindTexture(gl.TEXTURE_2D, u32(self.ident))
}

texture_unbind :: proc(self: ^Texture)
{
    gl.BindTexture(gl.TEXTURE_2D, 0)
}

texture_get_relative :: proc(self: ^Texture, position: [2]int) -> [2]f32
{
    if self == nil { return {} }

    return {
        clamp(f32(position.x) / f32(self.dimension.x), 0, 1),
        clamp(f32(position.y) / f32(self.dimension.y), 0, 1),
    }
}
