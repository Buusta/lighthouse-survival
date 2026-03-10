shader_type spatial;

render_mode diffuse_burley;

uniform sampler2D diffuse : hint_default_black;
uniform sampler2D roughness : hint_default_white;
uniform sampler2D normal : hint_normal;
uniform float normal_depth : hint_range(-2.0, 2.0, 0.01) = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = texture(diffuse, UV).rgb;
	ROUGHNESS = texture(roughness, UV).r;
	NORMAL_MAP = texture(normal, UV).rgb;
	NORMAL_MAP_DEPTH = normal_depth;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
