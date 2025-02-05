package pax

Sprite :: struct
{
    texture:   int,
    position:  [2]int,
    dimension: [2]int,
}

Animation :: struct
{
    sprite: int,
    size:   int,
    ticks:  int,
    loop:   b8,
}
