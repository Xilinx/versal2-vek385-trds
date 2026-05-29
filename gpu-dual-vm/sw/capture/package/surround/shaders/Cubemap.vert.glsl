
attribute vec3 a_pos;

uniform mat4 model_projection_matrix;

varying vec3 pos;

void main() {
	gl_Position = model_projection_matrix * vec4(a_pos, 1.0);
	pos = a_pos;
}
