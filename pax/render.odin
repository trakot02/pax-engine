package pax

import "core:log"

import sdl  "vendor:sdl2"
import sdli "vendor:sdl2/image"

Renderer :: struct
{
    //
    //
    //
    data: rawptr,
}

//
//
//
renderer_init :: proc(self: ^Renderer, window: ^Window) -> bool
{
    render_flags := sdl.RendererFlags {.ACCELERATED}

    self.data = auto_cast sdl.CreateRenderer(auto_cast window.data,
        -1, render_flags)

    if self.data == nil {
        log.errorf("SDL: %v", sdl.GetErrorString())

        return false
    }

    return true
}

//
//
//
renderer_destroy :: proc(self: ^Renderer)
{
    sdl.DestroyRenderer(auto_cast self.data)

    self.data = nil
}

Render_Context :: struct
{
    //
    //
    //
    renderer: ^Renderer,

    //
    //
    //
    camera: ^Camera,

    //
    //
    //
    images: ^Registry(Image),

    //
    //
    //
    sprites: ^Registry(Sprite),
}

//
//
//
render_clear :: proc(self: ^Render_Context, color: [4]u8 = {}) -> bool
{
    code := sdl.SetRenderDrawColor(auto_cast self.renderer.data,
        color.r, color.g, color.b, color.a)

    if code != 0 { return false }

    code = sdl.RenderClear(auto_cast self.renderer.data)

    if code != 0 { return false }

    return true
}

//
//
//
render_apply :: proc(self: ^Render_Context)
{
    sdl.RenderPresent(auto_cast self.renderer.data)
}

//
//
//
render_draw_sprite :: proc(self: ^Render_Context, visual: Visual, transform: Transform) -> bool
{
    value := visual.frame

    sprite := registry_find(self.sprites, visual.sprite) or_return
    image  := registry_find(self.images,  sprite.image)  or_return

    if visual.chain != 0 {
        chain := sprite_chain(sprite, visual.chain) or_return

        if 0 < chain.frame && chain.frame <= len(chain.frames) {
            value = chain.frames[chain.frame - 1]
        }
    }

    frame := sprite_frame(sprite, value) or_return

    point := [2]f32 {0, 0}
    scale := [2]f32 {1, 1}

    if self.camera != nil {
        point = camera_point(self.camera) - frame.base
        scale = camera_scale(self.camera) * transform.scale
    }

    part := sdl.Rect {
        i32(frame.rect.x), i32(frame.rect.y),
        i32(frame.rect.z), i32(frame.rect.w),
    }

    rect := sdl.Rect {
        i32(scale.x * (transform.point.x + point.x)),
        i32(scale.y * (transform.point.y + point.y)),
        i32(scale.x * f32(frame.rect.z)),
        i32(scale.y * f32(frame.rect.w)),
    }

    code := sdl.RenderCopy(auto_cast self.renderer.data,
        auto_cast image.data, &part, &rect)

    if code != 0 {
        log.errorf("SDL: %v", sdl.GetErrorString())

        return false
    }

    return true
}
