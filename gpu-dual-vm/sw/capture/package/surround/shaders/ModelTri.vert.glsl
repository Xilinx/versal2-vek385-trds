
attribute vec3 a_pos;

uniform mat4 model_matrix;
uniform mat4 projection_matrix;

varying vec3 pos;
flat varying float triangle_color_index;


void main() {
	vec4 world_pos = model_matrix * vec4(a_pos, 1.0);
	gl_Position = projection_matrix * world_pos;

	pos = world_pos.xyz;

	triangle_color_index =
			a_pos.x * 123.456 +
			a_pos.y * 234.567 +
			a_pos.z * 345.678;
}
