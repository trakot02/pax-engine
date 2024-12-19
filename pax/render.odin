package pax

import sdl  "vendor:sdl2"
import sdli "vendor:sdl2/image"

Render_State :: struct
{
    renderer: ^sdl.Renderer,

    camera: ^Camera,

    images:  [dynamic]Image,
    sprites: [dynamic]Sprite,
}

render_init :: proc(self: ^Render_State, allocator := context.allocator)
{
    self.images  = make([dynamic]Image,  allocator)
    self.sprites = make([dynamic]Sprite, allocator)
}

render_destroy :: proc(self: ^Render_State)
{
    delete(self.sprites)
    delete(self.images)
}

render_draw_sprite_frame :: proc(self: ^Render_State, visible: Visible, transform: Transform)
{
    if visible.sprite < 0 || visible.sprite >= len(self.sprites) { return }

    sprite := &self.sprites[visible.sprite]

    if sprite == nil { return }

    if visible.frame < 0 || visible.frame >= len(sprite.frames) { return }

    frame := &sprite.frames[visible.frame]

    if frame == nil { return }

    if sprite.image < 0 || sprite.image >= len(self.images) { return }

    image := &self.images[sprite.image]

    displ := [2]int {0, 0}
    scale := [2]f32 {1, 1}

    if self.camera != nil {
        displ = camera_displ(self.camera) - frame.base
        scale = camera_scale(self.camera) + transform.scale
    }

    part := sdl.Rect {
        i32(frame.rect.x), i32(frame.rect.y),
        i32(frame.rect.z), i32(frame.rect.w),
    }

    rect := sdl.Rect {
        i32(scale.x * f32(transform.point.x + displ.x)),
        i32(scale.y * f32(transform.point.y + displ.y)),
        i32(scale.x * f32(frame.rect.z)),
        i32(scale.y * f32(frame.rect.w)),
    }

    assert(sdl.RenderCopy(self.renderer, image.data, &part, &rect) == 0,
        sdl.GetErrorString())
}

render_draw_sprite_chain :: proc(self: ^Render_State, visible: Visible, transform: Transform)
{
    if visible.sprite < 0 || visible.sprite >= len(self.sprites) { return }

    sprite := &self.sprites[visible.sprite]

    if sprite == nil { return }

    if visible.chain < 0 || visible.chain >= len(sprite.chains) { return }

    chain := &sprite.chains[visible.chain]

    if chain.frame < 0 || chain.frame >= len(sprite.frames) { return }

    frame := &sprite.frames[chain.frames[chain.frame]]

    if frame == nil { return }

    if sprite.image < 0 || sprite.image >= len(self.images) { return }

    image := &self.images[sprite.image]

    displ := [2]int {0, 0}
    scale := [2]f32 {1, 1}

    if self.camera != nil {
        displ = camera_displ(self.camera) - frame.base
        scale = camera_scale(self.camera) + transform.scale
    }

    part := sdl.Rect {
        i32(frame.rect.x), i32(frame.rect.y),
        i32(frame.rect.z), i32(frame.rect.w),
    }

    rect := sdl.Rect {
        i32(scale.x * f32(transform.point.x + displ.x)),
        i32(scale.y * f32(transform.point.y + displ.y)),
        i32(scale.x * f32(frame.rect.z)),
        i32(scale.y * f32(frame.rect.w)),
    }

    assert(sdl.RenderCopy(self.renderer, image.data, &part, &rect) == 0,
        sdl.GetErrorString())
}

render_update_chain :: proc(self: ^Render_State, visible: ^Visible)
{
    if visible.sprite < 0 || visible.sprite >= len(self.sprites) { return }

    sprite := &self.sprites[visible.sprite]

    if sprite == nil { return }

    if visible.chain < 0 || visible.chain >= len(sprite.chains) { return }

    chain := &sprite.chains[visible.chain]

    if chain == nil { return }

    if chain.stop == false && visible.timer >= chain.delay {
        next := chain.frame + 1

        if chain.loop == true {
            next %= len(chain.frames)
        }

        if next < len(chain.frames) {
            chain.frame    = next
            visible.timer -= chain.delay
        }
    }
}

render_stop_chain :: proc(self: ^Render_State, visible: Visible, stop: bool)
{
    if visible.sprite < 0 || visible.sprite >= len(self.sprites) { return }

    sprite := &self.sprites[visible.sprite]

    if sprite == nil { return }

    if visible.chain < 0 || visible.chain >= len(sprite.chains) { return }

    chain := &sprite.chains[visible.chain]

    if chain == nil { return }

    chain.stop = stop
}
