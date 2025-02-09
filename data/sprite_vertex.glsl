#version 330 core

uniform mat4 u_view;

layout (location = 0) in vec2 b_position;
layout (location = 1) in vec2 b_texture;
layout (location = 2) in vec4 b_color;

out vec2 v_texture;
out vec4 v_color;

void main()
{
    gl_Position = u_view * vec4(b_position, 0, 1);

    v_texture = b_texture;
    v_color   = b_color;
}
