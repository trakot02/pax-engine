package pax

import "core:log"

import rl "vendor:raylib"

Render_Context :: struct
{
    //
    //
    //
    camera: ^Camera,

    //
    //
    //
    textures: ^Texture_Registry,

    //
    //
    //
    sprites: ^Sprite_Registry,
}

//
//
//
render_clear :: proc(self: ^Render_Context, color: [4]u8 = {})
{
    rl.ClearBackground(rl.Color {
        color.x, color.y, color.z, color.w,
    })
}

//
//
//
render_draw_sprite :: proc(self: ^Render_Context, visual: Visual, transform: Transform) -> bool
{
    value := visual.frame

    sprite  := sprite_registry_find(self.sprites, visual.sprite)     or_return
    texture := texture_registry_find(self.textures, sprite.texture)  or_return
    frame   := sprite_find_frame(sprite, visual.frame, visual.chain) or_return

    point := [2]f32 {0, 0}
    scale := [2]f32 {1, 1}

    if self.camera != nil {
        point = camera_point(self.camera) - frame.base
        scale = camera_scale(self.camera) * transform.scale
    }

    part := rl.Rectangle {
        f32(frame.rect.x), f32(frame.rect.y),
        f32(frame.rect.z), f32(frame.rect.w),
    }

    rect := rl.Rectangle {
        scale.x * (transform.point.x + point.x),
        scale.y * (transform.point.y + point.y),
        scale.x * f32(frame.rect.z),
        scale.y * f32(frame.rect.w),
    }

    rl.DrawTexturePro(texture^, part, rect, {0, 0}, 0,
        {255, 255, 255, 255})

    return true
}
