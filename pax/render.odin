package pax

import "core:log"
import "core:mem"
import "core:strings"

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

    //
    //
    //
    fonts: ^Font_Registry,
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

//
//
//
render_draw_text :: proc(self: ^Render_Context, text: Text, transform: Transform) -> bool
{
    alloc := context.allocator

    font := font_registry_find(self.fonts, text.font) or_return

    clone, error := strings.clone_to_cstring(text.content, alloc)

    if error != nil {
        log.errorf("Render: Unable to clone %q to c-string",
            text.content)

        return false
    }

    rl.DrawTextEx(font^, clone, transform.point, text.size, text.spacing, rl.Color {
        text.color.r, text.color.g, text.color.b, text.color.a,
    })

    mem.free_all(alloc)

    return true
}
