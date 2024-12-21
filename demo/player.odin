package demo

import sdl "vendor:sdl2"

import "../pax"

Player :: struct
{
    visual:    pax.Visual,
    transform: pax.Transform,
    motion:    Motion,
    controls:  Controls,

    camera: ^pax.Camera,
}
