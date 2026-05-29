
attribute vec2 a_pos;
attribute vec2 a_distance;

uniform float u_shift;

varying vec2 distance;

void main() {
	gl_Position = vec4((a_pos + vec2(u_shift, 0.0)) * 2.0 - vec2(1.0), 0.0, 1.0);
	distance = a_distance;
}
