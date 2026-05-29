
precision mediump float;

uniform sampler2D skybox;
uniform float opacity;

varying vec3 pos;
varying vec2 tx;

void main() {
	// gl_FragColor = textureCube(skybox, pos);
	gl_FragColor = texture2D(skybox, tx);
	gl_FragColor.a = opacity;
	// gl_FragColor = vec4(pos, 0.5);
	// gl_FragColor = vec4(1.0, 0.0, 1.0, 0.5);
}
