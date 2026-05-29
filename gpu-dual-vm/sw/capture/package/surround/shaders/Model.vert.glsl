
attribute vec3 a_pos;
attribute vec3 a_normal;

#ifdef USE_SEPARATE_MODEL_PROJECTION
uniform mat4 model_matrix;
uniform mat4 projection_matrix;
#else
uniform mat4 model_projection_matrix;
#endif
uniform mat3 normal_matrix;

varying vec3 pos;
varying vec3 normal;

#if 0
varying vec3 mpos;
varying vec3 mnormal;
#endif


void main() {
#ifdef USE_SEPARATE_MODEL_PROJECTION

	vec4 world_pos = model_matrix * vec4(a_pos, 1.0);

	gl_Position = projection_matrix * world_pos;

	pos = world_pos.xyz;

#if 0
	mpos = a_pos;
	mnormal = a_normal;
#endif

#else

	gl_Position = model_projection_matrix * vec4(a_pos, 1.0);

#endif

	normal = normal_matrix * a_normal;
}
