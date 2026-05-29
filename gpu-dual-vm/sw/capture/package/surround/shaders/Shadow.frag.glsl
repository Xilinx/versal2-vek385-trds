
precision mediump float;

uniform sampler2D texture;
uniform float opacity;

varying vec2 tx;


void main() {
	gl_FragColor = texture2D(texture, tx);
	// gl_FragColor.rgb = mix(vec3(1.0, 0.0, 1.0), vec3(0.0), gl_FragColor.a);
	// gl_FragColor.a = 1.0;
	gl_FragColor.a *= opacity;
}
