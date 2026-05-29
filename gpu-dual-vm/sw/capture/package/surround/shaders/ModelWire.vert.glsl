
attribute vec3 a_pos;

uniform mat4 model_matrix;
uniform mat4 projection_matrix;

varying vec3 pos;


void main() {
	vec4 world_pos = model_matrix * vec4(a_pos, 1.0);
	gl_Position = projection_matrix * world_pos;
	pos = world_pos.xyz;
}
