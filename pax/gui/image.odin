package gui

import "core:log"

import res "../res"

Image_Group :: struct
{
    slot:  int,
    scale: [2]f32,
    rect:  [4]f32,
}

//
//
//
compute_image_size :: proc(state: ^State, handle: Handle, image: ^Image_Group)
{
    parent  := find_parent(state, handle)
    texture := find_texture(state, image.slot)

    handle.bounds.zw = handle.offset.zw

    if texture.slot != 0 {
        image.rect.zw = {
            f32(texture.value.width),
            f32(texture.value.height),
        }

        handle.bounds.z += image.scale.x * image.rect.z
        handle.bounds.w += image.scale.y * image.rect.w
    }

    if parent.slot != 0 {
        handle.bounds.zw += handle.factor.zw *
            parent.bounds.zw
    }

    image.rect.xy = handle.bounds.zw / 2 - (image.scale.xy * image.rect.zw) / 2

    compute_rec_size(state, handle)
}

//
//
//
compute_image_part :: proc(state: ^State, handle: Handle, image: ^Image_Group, size: [2]f32)
{
    texture := find_texture(state, image.slot)

    handle.bounds.zw = handle.offset.zw

    if texture.slot != 0 {
        image.rect.zw = {
            f32(texture.value.width),
            f32(texture.value.height),
        }

        handle.bounds.z += image.scale.x * image.rect.z
        handle.bounds.w += image.scale.y * image.rect.w
    }

    handle.bounds.zw += handle.factor.zw * size

    image.rect.xy = handle.bounds.zw / 2 - (image.scale.xy * image.rect.zw) / 2

    compute_rec_size(state, handle)
}

//
//
//
compute_image_pos :: proc(state: ^State, handle: Handle, image: ^Image_Group)
{
    compute_own_pos(state, handle)
    compute_rec_pos(state, handle)
}
