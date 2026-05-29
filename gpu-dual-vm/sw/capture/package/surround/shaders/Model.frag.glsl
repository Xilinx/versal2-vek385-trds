
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

#ifdef USE_CUBEMAP_REFLECTION
uniform samplerCube skybox;
uniform float skybox_specular;
#endif

varying vec3 pos;
varying vec3 normal;

#if 0
varying vec3 mpos;
varying vec3 mnormal;
#endif

#ifdef STATIC_LIGHT
const vec3 light_dir = normalize(vec3(0.0, -1.0, 0.0));
// const vec3 light_dir = normalize(vec3(1.0, -2.0, 0.5));
// const vec3 light_dir = normalize(vec3(0.0, -1.0, 0.0));
// const vec3 light_dir = normalize(vec3(1.0, 0.0, 0.0));

// const float light_pow = 25.0;
const float light_pow = 4.0;
// const float light_pow = 2.0;
// const float light_pow = 1.0;
// const float light_pow = 0.2;
#else
uniform vec3 light_dir;
uniform float light_pow;
#endif

// const vec3 light_color = vec3(0.6, 0.8, 1.0);
// const vec3 light_color = vec3(0.9, 0.8, 0.6);
const vec3 light_color = vec3(1.0);


void main() {
	vec3 camera_dir = normalize(camera_pos - pos);

#if 0
// gl_FragColor = vec4((normalize(normal) + 1.0) * 0.5, 1.0);
// gl_FragColor = vec4(mnormal, 1.0);
gl_FragColor = vec4(normal, 1.0);
// gl_FragColor = vec4(mpos, 1.0);
return;
#endif

	float light_factor = -dot(normal, light_dir);

	float specular_factor;
	if (light_factor <= 0.0) {
		specular_factor = 0.0;
	} else {
		vec3 refl_dir = reflect(light_dir, normal);
		// specular_factor = max(0.0, dot(refl_dir, vec3(0.0, 0.0, 1.0)));
		specular_factor = max(0.0, dot(refl_dir, camera_dir));
		specular_factor = pow(specular_factor, light_pow);
	}

	light_factor = smoothstep(-0.1, 0.1, light_factor);
	vec3 diffuse_color = mat_diffuse * mix(0.5, 1.0, light_factor);

	// vec3 color = mat_diffuse;
	vec3 color = diffuse_color;

	vec4 self_opaque_color = vec4(mat_ambient + color, 1.0);
	// vec4 self_opaque_color = vec4(color.rgb, 1.0);
#ifdef USE_BLEND
	self_opaque_color *= mat_dissolve;
#endif

	vec3 self_specular_color = mat_specular * light_color;

#ifdef USE_BLEND
	self_specular_color = light_color;
#endif

	// gl_FragColor = vec4(color, 1.0);
	// gl_FragColor = vec4(normal, 1.0);
	// return;
	gl_FragColor = mix(self_opaque_color, vec4(self_specular_color, 1.0), specular_factor);

#ifdef USE_CUBEMAP_REFLECTION
	vec3 skybox_vec = reflect(-camera_dir, normal);
	vec3 skybox_color = textureCube(skybox, skybox_vec).rgb;
	gl_FragColor = mix(gl_FragColor, vec4(skybox_color, 1.0), skybox_specular * 0.4);
#endif
}
