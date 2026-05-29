
precision mediump float;

uniform sampler2D texture;

varying vec2 tx;

void main() {
	gl_FragColor = texture2D(texture, tx);
	// gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
