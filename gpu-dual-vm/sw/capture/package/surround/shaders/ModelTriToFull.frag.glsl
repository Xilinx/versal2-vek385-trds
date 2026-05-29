#version 300 es

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

uniform float color_index;
uniform sampler2D color_texture;

uniform float wire_transition;

in vec3 pos;
in vec3 normal;

flat in float triangle_color_index;
in vec3 edge1;
in float edge_pos;

out vec4 FragColor;


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

const float edge_width = 0.2;


float calc_edge(in vec3 edge) {
	float a = min(min(edge.x, edge.y), edge.z);
	return max(0.0, edge_width - a) / edge_width;
}


void main() {
	float e1 = calc_edge(edge1);
	float transition = smoothstep(-0.5, 0.5, edge_pos + (wire_transition - 0.5) * 8.0);
	if (e1 == 0.0 && transition == 0.0) discard;

	vec3 camera_dir = normalize(camera_pos - pos);

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
	vec4 full_color = mix(self_opaque_color, vec4(self_specular_color, 1.0), specular_factor);

#ifdef USE_CUBEMAP_REFLECTION
	vec3 skybox_vec = reflect(-camera_dir, normal);
	vec3 skybox_color = texture(skybox, skybox_vec).rgb;
	full_color = mix(full_color, vec4(skybox_color, 1.0), skybox_specular * 0.4);
#endif

	// gl_FragColor.a *= wire_transition;

	vec3 wire_color = texture(color_texture, vec2(color_index +
			triangle_color_index +
			edge_pos, 0.5)).rgb;

	vec4 tri_color = vec4(wire_color * e1, 1.0);

	FragColor = mix(tri_color, full_color, transition);
}
