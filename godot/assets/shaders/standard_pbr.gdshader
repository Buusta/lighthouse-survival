shader_type spatial;
render_mode diffuse_burley;

uniform sampler2D aorm : hint_default_white, filter_linear_mipmap_anisotropic;
uniform sampler2D diffuse : hint_default_white, filter_linear_mipmap_anisotropic;
uniform sampler2D normal : hint_normal, filter_linear_mipmap_anisotropic;
uniform float normal_depth = 1.0;

uniform vec2 uv_tiling = vec2(1.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 aorm_tex = texture(aorm, UV * uv_tiling).rgb;
	vec3 diffuse_tex = texture(diffuse, UV * uv_tiling).rgb;
	vec3 normal_tex = texture(normal, UV * uv_tiling).rgb;

	ALBEDO = diffuse_tex * aorm_tex.r;
	ROUGHNESS = aorm_tex.g;
	NORMAL_MAP = normal_tex;
	NORMAL_MAP_DEPTH = normal_depth;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
