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
}

Texture_Builder :: struct
{
    dimension: [2]int,
    channels:  int,
    bytes:     [^]byte,
}

//
// Functions
//

texture_set_dimension :: proc(self: ^Texture_Builder, dimension: [2]int)
{
    self.dimension = dimension
}

texture_set_channels :: proc(self: ^Texture_Builder, channels: int)
{
    self.channels = channels
}

texture_set_bytes :: proc(self: ^Texture_Builder, bytes: [^]byte)
{
    self.bytes = bytes
}

texture_init :: proc(self: ^Texture_Builder) -> (Texture, bool)
{
    ident  := u32(0)
    width  := i32(self.dimension.x)
    height := i32(self.dimension.y)

    gl.GenTextures(1, &ident)
    gl.BindTexture(gl.TEXTURE_2D, ident)

    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA,
        gl.UNSIGNED_BYTE, self.bytes)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

    gl.BindTexture(gl.TEXTURE_2D, 0)

    self^ = {}

    return Texture {
        ident     = int(ident),
        dimension = {int(width), int(height)},
    }, true
}

texture_read :: proc(self: ^Texture_Builder, name: string) -> (Texture, bool)
{
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

    defer stbi.image_free(self.bytes)

    texture_set_dimension(self, {int(width), int(height)})
    texture_set_channels(self, int(channels))
    texture_set_bytes(self, bytes)

    return texture_init(self)
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
