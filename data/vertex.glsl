#version 330 core

layout (location = 0) in vec2 data_position;
layout (location = 1) in vec4 data_color;

out vec4 vert_color;

void main()
{
    gl_Position = vec4(data_position, 0, 1);
    vert_color  = data_color;
}
