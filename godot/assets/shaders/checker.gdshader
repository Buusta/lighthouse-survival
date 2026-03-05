shader_type spatial;

uniform float texel_density = 1.0;
uniform sampler2D albedo : source_color;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 check = floor(world_position.yz * texel_density);
	ALBEDO = texture(albedo, world_position.yz * texel_density).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
