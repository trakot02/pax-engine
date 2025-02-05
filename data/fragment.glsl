#version 330 core

uniform sampler2D unif_texture_0;

in vec4 vert_color;
in vec2 vert_texture;

out vec4 frag_color;

void main()
{
    frag_color = vert_color * texture(unif_texture_0, vert_texture);
}
