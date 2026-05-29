
attribute vec3 a_pos;
attribute vec2 a_tx;

uniform mat4 model_projection_matrix;

varying vec3 pos;
varying vec2 tx;

void main() {
	gl_Position = model_projection_matrix * vec4(a_pos, 1.0);
	pos = a_pos;
	tx = a_tx;
}
