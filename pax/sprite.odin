package pax

import gl "vendor:OpenGL"

SPRITE_BUFFER_SIZE :: RENDER_BUFFER_SIZE / size_of(Sprite_Vertex)

SPRITE_VERTEX_SHADER   :: #load("../data/sprite_vertex.glsl")
SPRITE_FRAGMENT_SHADER :: #load("../data/sprite_fragment.glsl")

Sprite :: struct
{
    frame:     [4]int,
    dimension: [2]f32,
    color:     [4]f32,
}

Animation :: struct
{
    position:  [2]int,
    dimension: [2]int,
    region:    [2]int,
    delay:     f32,
    timer:     f32,
    count:     int,
    index:     int,
}

Sprite_Vertex :: struct
{
    position: [2]f32,
    texture:  [2]f32,
    color:    [4]f32,
}

Sprite_Batch :: struct
{
    shader:  ^Shader,
    view:    ^View,
    texture: ^Texture,

    count: int,
    items: [SPRITE_BUFFER_SIZE]Sprite_Vertex,
}

animation_init :: proc(delay: f32, position: [2]int, dimension: [2]int, region: [2]int) -> Animation
{
    return Animation {
        position  = position,
        dimension = dimension,
        region    = region,
        delay     = delay,
        count     = dimension.x / region.x,
    }
}

animation_set_delay :: proc(self: ^Animation, delay: f32)
{
    self.delay = max(delay, 0)
}

animation_add_delay :: proc(self: ^Animation, delay: f32)
{
    animation_set_delay(self, self.delay + delay)
}

animation_tick :: proc(self: ^Animation, delta_time: f32)
{
    self.timer += delta_time

    if self.delay <= 0 { return }

    for self.timer >= self.delay {
        self.index += 1
        self.index %= self.count

        self.timer -= self.delay
    }
}

animation_get_frame :: proc(self: ^Animation) -> [4]int
{
    offset := self.region.x * self.index

    return {
        self.position.x + offset,
        self.position.y,
        self.region.x,
        self.region.y,
    }
}

sprite_batch_set_shader :: proc(self: ^Sprite_Batch, shader: ^Shader)
{
    self.shader = shader
}

sprite_batch_set_view :: proc(self: ^Sprite_Batch, view: ^View)
{
    self.view = view
}

sprite_batch_set_texture :: proc(self: ^Sprite_Batch, texture: ^Texture)
{
    self.texture = texture
}

sprite_batch_begin :: proc(self: ^Sprite_Batch, render: ^Render_State)
{
    self.texture = &render.white_texture
}

sprite_batch_flush :: proc(self: ^Sprite_Batch, render: ^Render_State)
{
    size  := size_of(Sprite_Vertex)
    count := self.count
    bytes := count * size

    if bytes != 0 {
        gl.BindBuffer(gl.ARRAY_BUFFER, u32(render.buffer))

        gl.EnableVertexAttribArray(0)
        gl.EnableVertexAttribArray(1)
        gl.EnableVertexAttribArray(2)

        gl.VertexAttribPointer(0, 2, gl.FLOAT, false, i32(size),
            offset_of(Sprite_Vertex, position))

        gl.VertexAttribPointer(1, 2, gl.FLOAT, false, i32(size),
            offset_of(Sprite_Vertex, texture))

        gl.VertexAttribPointer(2, 4, gl.FLOAT, false, i32(size),
            offset_of(Sprite_Vertex, color))

        gl.BufferSubData(gl.ARRAY_BUFFER, 0, bytes, &self.items[0])

        if self.shader  != nil { shader_bind(self.shader) }
        if self.texture != nil { texture_bind(self.texture) }

        if self.view != nil {
            left   := self.view.viewport.x
            top    := self.view.viewport.y
            width  := self.view.viewport.z
            height := self.view.viewport.w

            gl.Viewport(i32(left), i32(top), i32(width), i32(height))
        }

        if self.shader != nil && self.view != nil {
            shader_set_mat4_f32(self.shader, "u_view", view_get_mat4_f32(self.view))
        }

        gl.DrawArrays(gl.TRIANGLES, 0, i32(count))
    }

    self.count   = 0
    self.shader  = nil
    self.texture = nil
    self.view    = nil
}

sprite_batch_push :: proc(self: ^Sprite_Batch, sprite: Sprite, transform: Transform = {})  -> bool
{
    count := self.count + 6

    if count >= len(self.items) {
        return false
    }

    trans       := transform
    trans.pivot *= sprite.dimension

    self.items[self.count + 0].position = transform_vec2_f32(trans, {0, 0})
    self.items[self.count + 1].position = transform_vec2_f32(trans, {0, sprite.dimension.y})
    self.items[self.count + 2].position = transform_vec2_f32(trans, {sprite.dimension.x, 0})
    self.items[self.count + 3].position = transform_vec2_f32(trans, {sprite.dimension.x, 0})
    self.items[self.count + 4].position = transform_vec2_f32(trans, {0, sprite.dimension.y})
    self.items[self.count + 5].position = transform_vec2_f32(trans, sprite.dimension.xy)

    self.items[self.count + 0].texture = texture_get_relative(self.texture, sprite.frame.xy)
    self.items[self.count + 1].texture = texture_get_relative(self.texture, sprite.frame.xy + {0, sprite.frame.w})
    self.items[self.count + 2].texture = texture_get_relative(self.texture, sprite.frame.xy + {sprite.frame.z, 0})
    self.items[self.count + 3].texture = texture_get_relative(self.texture, sprite.frame.xy + {sprite.frame.z, 0})
    self.items[self.count + 4].texture = texture_get_relative(self.texture, sprite.frame.xy + {0, sprite.frame.w})
    self.items[self.count + 5].texture = texture_get_relative(self.texture, sprite.frame.xy + sprite.frame.zw)

    for index in 0 ..< 6 {
        self.items[self.count + index].color = sprite.color
    }

    self.count = count

    return true
}

sprite_shader :: proc() -> (Shader, bool)
{
    builder := Shader_Builder {}

    shader_set_vertex(&builder, string(SPRITE_VERTEX_SHADER))
    shader_set_fragment(&builder, string(SPRITE_FRAGMENT_SHADER))

    return shader_init(&builder)
}
