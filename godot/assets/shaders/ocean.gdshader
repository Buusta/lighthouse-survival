shader_type spatial;
render_mode cull_disabled, depth_draw_always;

varying vec3 world_position;

uniform int wave_count = 8;
uniform vec2 wind_dir = vec2(1.0, 0.0);
uniform float spread : hint_range(0.0, 1.0) = 0.5;
uniform float base_frequency : hint_range(0.0, 5.0) = 0.5;
uniform float base_amplitude : hint_range(0.0, 10.0) = 0.5;
uniform float fbm_frequency : hint_range(1.0, 2.0) = 1.4;
uniform float fbm_amplitude : hint_range(0.0, 1.0) = 0.65;
uniform float base_steepness : hint_range(0.0, 5.0) = 0.5;

uniform float cascade_scale = 1.0;
uniform float wind_speed = 1.0;
uniform float warp_strength = 1.0;
varying vec3 wave_normal;
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.01;

uniform float seed = 42;

uniform sampler2D normal_map_1 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale = 5.0;
uniform float normal_depth : hint_range(-1.0, 1.0, 0.01) = 0.33;

//filter_linear filter_linear_mipmap_anisotropic filter_linear_mipmap, filter_nearest_mipmap_anisotropic

uniform vec3 water_color : source_color = vec3(0.0, 0.3, 0.5);
uniform vec3 absorption_coeffs : source_color = vec3(0.0, 0.3, 0.5);
uniform float absorption_density : hint_range(0.0, 1.0, 0.001) = 0.2;
uniform float transparent_depth_density : hint_range(0.0, 1.0, 0.001) = 0.33;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float refraction_strength : hint_range(0.0, 8.0, 0.001) = 0.5;

float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float displacement = 0.0;
	vec2 derivative = vec2(0.0);

	vec2 sample_pos = world_position.xz;
	vec3 gerstner = vec3(0.0);

	for (int i = 0; i < wave_count; i++) {
		float f = float(i);

		float angle = hash(f + seed) * PI * 2.0;
		vec2 rand_dir = vec2(cos(angle), sin(angle));
		vec2 dir = normalize(mix(wind_dir, rand_dir, spread));
        
		float freq = base_frequency * pow(fbm_frequency, f);
		float amp = base_amplitude * pow(fbm_amplitude, f);
        float phase = hash(f + 0.5 + seed) * PI * 2.0;
        
		float wave_val = dot(dir, world_position.xz) * freq + TIME * wind_speed + phase;

		gerstner.x += base_steepness * amp * dir.x * cos(wave_val);
		gerstner.z += base_steepness * amp * dir.y * cos(wave_val);
		gerstner.y += amp * sin(wave_val);

		derivative += amp * freq * cos(wave_val) * dir;
	}
	VERTEX.xyz += gerstner;
	// normal from derivative: flat plane normal (0,1,0) perturbed by slope
	wave_normal = normalize(vec3(-derivative.x, 1.0, -derivative.y));
}

void fragment() {
	NORMAL = (VIEW_MATRIX * vec4(wave_normal, 0.0)).xyz;
	
	//ALBEDO = water_color.rgb;

	ROUGHNESS = roughness; //1.0 - fresnel * roughness;

	NORMAL_MAP = texture(normal_map_1, world_position.xz * normal_scale).rgb;
	NORMAL_MAP_DEPTH = normal_depth;

	float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	
	vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view_pos.xyz /= view_pos.w;
	vec4 world_pos = INV_VIEW_MATRIX * view_pos;

	float scene_depth = -view_pos.z;

	// Depth of water surface in view space  
	float water_depth = -VERTEX.z;

	float depth_diff = scene_depth - water_depth;

	// Scene geometry in view space (you already have this)
	vec3 scene_view_pos = view_pos.xyz;

	// Water surface is just VERTEX (already view space)
	vec3 water_view_pos = VERTEX;

	// 3D distance through water
	float dist = distance(scene_view_pos, water_view_pos);
	float depth_fade = clamp(dist / 20.0, 0.0, 1.0);
	depth_fade = exp(-dist * absorption_density);

	vec3 absorption = absorption_coeffs * absorption_density;
	vec3 transmitted = exp(-dist * absorption);

	//vec3 water_color_depth = mix(water_color_deep, water_color, depth_fade);

	vec2 refract_uv = SCREEN_UV + NORMAL.xy * refraction_strength;
	// But clamp depth check so you don't refract onto above-water geometry
	float refract_depth = textureLod(DEPTH_TEXTURE, refract_uv, 0.0).r;
	vec2 final_uv = refract_depth > depth ? refract_uv : SCREEN_UV;
	vec3 screen_color = texture(SCREEN_TEXTURE, final_uv).rgb;
	ALBEDO =  mix(screen_color * transmitted, water_color.rgb, 1.0 - transmitted);

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
