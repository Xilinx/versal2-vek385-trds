
attribute vec2 a_pos;
attribute vec2 a_tx;
#ifdef STITCH_BLEND
attribute float a_alpha;
#endif

uniform float u_shift;

varying vec2 tx;
#ifdef STITCH_BLEND
varying float alpha;
#endif


void main() {
	gl_Position = vec4((a_pos + vec2(u_shift, 0.0)) * 2.0 - vec2(1.0), 0.0, 1.0);

	tx = a_tx;

#ifdef STITCH_BLEND
	alpha = a_alpha;
#endif
}
