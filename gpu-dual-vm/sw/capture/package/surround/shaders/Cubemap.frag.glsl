
precision mediump float;

uniform samplerCube skybox;
uniform float opacity;

varying vec3 pos;

void main() {
	// gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
	// gl_FragColor = vec4((pos + vec3(1.0)) * 0.5, 1.0);
	// gl_FragColor = vec4((pos + vec3(0.6)) / 1.6, 1.0);
	gl_FragColor = textureCube(skybox, pos);
	gl_FragColor.a = opacity;
}
