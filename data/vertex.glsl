#version 330 core

uniform mat4 unif_view;

layout (location = 0) in vec2 data_position;
layout (location = 1) in vec4 data_color;

out vec4 vert_color;

void main()
{
    gl_Position = unif_view * vec4(data_position, 0, 1);
    vert_color  = data_color;
}
