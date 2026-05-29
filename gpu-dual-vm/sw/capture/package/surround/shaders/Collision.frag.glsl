
precision mediump float;

varying vec2 distance;

void main() {
	gl_FragColor = vec4(distance, 0.0, 1.0);
}
