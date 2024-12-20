package pax

import "core:log"

import sdl  "vendor:sdl2"
import sdli "vendor:sdl2/image"

Render_State :: struct
{
    renderer: rawptr,

    camera:  ^Camera,
    images:  ^Registry(Image),
    sprites: ^Registry(Sprite),
}

render_draw_sprite_frame :: proc(self: ^Render_State, visual: Visual, transform: Transform) -> bool
{
    sprite := registry_find(self.sprites, visual.sprite) or_return
    image  := registry_find(self.images,  sprite.image)  or_return

    frame := sprite_frame(sprite, visual.frame) or_return

    pivot := [2]f32 {0, 0}
    scale := [2]f32 {1, 1}

    if self.camera != nil {
        pivot = camera_pivot(self.camera) - frame.base
        scale = camera_scale(self.camera) * transform.scale
    }

    part := sdl.Rect {
        i32(frame.rect.x), i32(frame.rect.y),
        i32(frame.rect.z), i32(frame.rect.w),
    }

    rect := sdl.Rect {
        i32(scale.x * f32(transform.pivot.x + pivot.x)),
        i32(scale.y * f32(transform.pivot.y + pivot.y)),
        i32(scale.x * f32(frame.rect.z)),
        i32(scale.y * f32(frame.rect.w)),
    }

    copy := sdl.RenderCopy(auto_cast self.renderer, auto_cast image.data,
        &part, &rect)

    if copy != 0 {
        log.errorf("SDL: %v\n", sdl.GetErrorString())

        return false
    }

    return true
}

render_draw_sprite_chain :: proc(self: ^Render_State, visual: Visual, transform: Transform) -> bool
{
    sprite := registry_find(self.sprites, visual.sprite) or_return
    image  := registry_find(self.images,  sprite.image)  or_return

    chain := sprite_chain(sprite, visual.chain) or_return

    if chain.frame <= 0 || chain.frame > len(chain.frames) { return false }

    frame := sprite_frame(sprite, chain.frames[chain.frame - 1])  or_return

    pivot := [2]f32 {0, 0}
    scale := [2]f32 {1, 1}

    if self.camera != nil {
        pivot = camera_pivot(self.camera) - frame.base
        scale = camera_scale(self.camera) * transform.scale
    }

    part := sdl.Rect {
        i32(frame.rect.x), i32(frame.rect.y),
        i32(frame.rect.z), i32(frame.rect.w),
    }

    rect := sdl.Rect {
        i32(scale.x * f32(transform.pivot.x + pivot.x)),
        i32(scale.y * f32(transform.pivot.y + pivot.y)),
        i32(scale.x * f32(frame.rect.z)),
        i32(scale.y * f32(frame.rect.w)),
    }

    copy := sdl.RenderCopy(auto_cast self.renderer, auto_cast image.data,
        &part, &rect)

    if copy != 0 {
        log.errorf("SDL: %v\n", sdl.GetErrorString())

        return false
    }

    return true
}

render_update_chain :: proc(self: ^Render_State, visual: Visual, delta: f32) -> bool
{
    sprite := registry_find(self.sprites, visual.sprite) or_return
    chain  := sprite_chain(sprite, visual.chain)         or_return

    chain.timer += delta

    if chain.timer >= chain.delay {
        chain.timer -= chain.delay

        if chain.stop == false {
            chain.frame %= len(chain.frames)
            chain.frame += 1
        }
    }

    return true
}

render_stop_chain :: proc(self: ^Render_State, visual: Visual, stop: bool) -> bool
{
    sprite := registry_find(self.sprites, visual.sprite) or_return
    chain  := sprite_chain(sprite, visual.chain)         or_return

    chain.stop = stop

    return true
}
