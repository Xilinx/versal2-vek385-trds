
#ifdef USE_DMA
#extension GL_OES_EGL_image_external : require
#endif

precision mediump float;

#ifdef USE_DMA
uniform samplerExternalOES texture;
#else
uniform sampler2D texture;
#endif
uniform float opacity;

varying vec2 tx;


void main() {
	gl_FragColor = texture2D(texture, tx);
	gl_FragColor.a = opacity;
}
