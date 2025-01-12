package gui

import "core:log"

import res "../res"

Image_Group :: struct
{
    slot:  int,
    scale: [2]f32,
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
        handle.bounds.w += image.scale.x * f32(texture.value.height)
        handle.bounds.z += image.scale.y * f32(texture.value.width)
    }

    if parent.slot != 0 {
        handle.bounds.zw += handle.factor.zw *
            parent.bounds.zw
    }

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
        handle.bounds.w += image.scale.x * f32(texture.value.height)
        handle.bounds.z += image.scale.y * f32(texture.value.width)
    }

    handle.bounds.zw += handle.factor.zw * size

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
