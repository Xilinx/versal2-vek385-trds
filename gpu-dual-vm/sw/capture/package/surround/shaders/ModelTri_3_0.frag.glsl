#version 300 es

precision mediump float;

uniform float color_index;
uniform sampler2D color_texture;

in vec3 pos;
flat in float triangle_color_index;
in vec3 edge1;
in float edge_pos;

out vec4 FragColor;

const float edge_width = 0.2;


float calc_edge(in vec3 edge) {
	float a = min(min(edge.x, edge.y), edge.z);
	return max(0.0, edge_width - a) / edge_width;
}


void main() {
	float e1 = calc_edge(edge1);
	if (e1 == 0.0) discard;

	vec3 color = texture(color_texture, vec2(color_index +
			triangle_color_index +
			edge_pos, 0.5)).rgb;

	FragColor = vec4(color * e1, 1.0);

	// gl_FragColor = vec4(edge, 1.0);
}
