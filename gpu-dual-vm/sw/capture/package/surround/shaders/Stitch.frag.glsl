
#ifdef USE_DMA
#extension GL_OES_EGL_image_external : require
#endif

precision mediump float;

#ifdef USE_DMA
uniform samplerExternalOES texture;
#else
uniform sampler2D texture;
#endif

varying vec2 tx;
#ifdef STITCH_BLEND
varying float alpha;
#else
const float alpha = 1.0;
#endif


void main() {
	gl_FragColor = vec4(texture2D(texture, tx).rgb, alpha);
}
