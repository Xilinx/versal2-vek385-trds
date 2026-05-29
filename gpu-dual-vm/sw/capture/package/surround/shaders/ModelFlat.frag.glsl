
#ifdef OES
#extension GL_OES_EGL_image_external : require
#endif

precision mediump float;

uniform vec3 mat_ambient;
uniform vec3 mat_diffuse;
uniform vec3 mat_specular;
#ifdef USE_BLEND
uniform float mat_dissolve;
#endif
uniform vec3 camera_pos;

varying vec3 pos;
varying vec3 normal;

const vec3 light_dir = normalize(vec3(1.0, -2.0, 0.5));
// const vec3 light_dir = normalize(vec3(0.0, -1.0, 0.0));

const vec3 light_color = vec3(0.6, 0.8, 1.0);
// const vec3 light_color = vec3(1.0);

// const float specular_pow = 25.0;
// const float specular_pow = 2.0;
const float specular_pow = 1.0;

void main() {
	gl_FragColor = vec4(pos, 1.0);
}
