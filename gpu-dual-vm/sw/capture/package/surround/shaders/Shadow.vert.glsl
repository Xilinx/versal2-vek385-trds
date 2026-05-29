
attribute vec2 a_pos;

uniform mat4 u_matrix;
uniform float u_scale_factor;

varying vec2 tx;


void main() {
	float radius = length(a_pos);

	vec2 sq_pos = a_pos / max(abs(a_pos.x), abs(a_pos.y)) * radius;

	vec2 scaled_pos = mix(a_pos, sq_pos, u_scale_factor);

	// tx = (scaled_tx + 1.0) * 0.5;
	tx = (a_pos + 1.0) * 0.5;

	gl_Position = u_matrix * vec4(scaled_pos, 0.0, 1.0);
}
