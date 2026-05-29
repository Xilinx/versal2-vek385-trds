
precision mediump float;

uniform float color_index;
uniform sampler2D color_texture;

varying vec3 pos;
flat varying float triangle_color_index;


void main() {
	vec3 color = texture2D(color_texture, vec2(color_index +
			triangle_color_index +
			pos.x + pos.y + pos.z, 0.5)).rgb;
	// color = vec3(1.0);
	gl_FragColor = vec4(color, 1.0);
}
