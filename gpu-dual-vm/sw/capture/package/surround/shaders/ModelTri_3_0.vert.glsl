#version 300 es

layout(location = 0) in vec3 a_pos;

uniform mat4 model_matrix;
uniform mat4 projection_matrix;

out vec3 pos;
flat out float triangle_color_index;
out vec3 edge1;
out float edge_pos;


void main() {
	vec4 world_pos = model_matrix * vec4(a_pos, 1.0);
	gl_Position = projection_matrix * world_pos;

	pos = world_pos.xyz;

	triangle_color_index = float(gl_VertexID) * 0.05;

	edge1 = vec3(0.0);
	edge1[gl_VertexID % 3] = 1.0;

	edge_pos = a_pos.x + a_pos.y - a_pos.z;
}
