#version 330 core

uniform sampler2D u_texture_0;

in vec2 v_texture;
in vec4 v_color;

out vec4 f_color;

void main()
{
    f_color = v_color * texture(u_texture_0, v_texture);
}
