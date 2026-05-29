
attribute vec2 a_pos;
attribute vec2 a_dist;

varying vec2 tx;

void main() {
	gl_Position = vec4(a_pos, 0.0, 1.0);
	tx = (a_dist + vec2(1.0)) * 0.5;
}
