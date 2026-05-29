
attribute vec2 a_pos;
attribute vec2 a_dist;

uniform mat4 u_matrix;
uniform vec4 u_tx_range;

varying vec2 tx;


void main() {
	gl_Position = u_matrix * vec4(a_pos, 0.0, 1.0);

	vec2 abs_tx = (a_dist + 1.0) * 0.5;

	tx = vec2(
		mix(u_tx_range[0], u_tx_range[2], abs_tx.x),
		mix(u_tx_range[1], u_tx_range[3], abs_tx.y)
	);
}
