#version 300 es

layout(location = 0) in vec3 a_pos;
layout(location = 1) in vec3 a_normal;

#ifdef USE_SEPARATE_MODEL_PROJECTION
uniform mat4 model_matrix;
uniform mat4 projection_matrix;
#else
uniform mat4 model_projection_matrix;
#endif
uniform mat3 normal_matrix;

out vec3 pos;
out vec3 normal;

flat out float triangle_color_index;
out vec3 edge1;
out float edge_pos;


void main() {
#ifdef USE_SEPARATE_MODEL_PROJECTION

	vec4 world_pos = model_matrix * vec4(a_pos, 1.0);

	gl_Position = projection_matrix * world_pos;

	pos = world_pos.xyz;

#else

	gl_Position = model_projection_matrix * vec4(a_pos, 1.0);

#endif

	normal = normal_matrix * a_normal;

	triangle_color_index = float(gl_VertexID) * 0.05;

	edge1 = vec3(0.0);
	edge1[gl_VertexID % 3] = 1.0;

	edge_pos = a_pos.x + a_pos.y - a_pos.z;
}
