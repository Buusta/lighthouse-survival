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
uniform float omega_range = 3.0;
uniform float omega_min = 0.5;
uniform float fetch = 10000000.0;

uniform float wind_speed = 10.0;
varying vec3 wave_normal;
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.01;

uniform float seed = 42;

uniform sampler2D normal_map_1 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale = 5.0;
uniform float normal_depth : hint_range(-1.0, 1.0, 0.01) = 0.33;

uniform vec3 water_color : source_color = vec3(0.0, 0.3, 0.5);
uniform vec3 absorption_coeffs : source_color = vec3(0.0, 0.3, 0.5);
uniform float absorption_density : hint_range(0.0, 1.0, 0.001) = 0.2;
uniform float alpha_fade_distance : hint_range(0.0, 8.0, 0.001) = 3.0;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;

uniform float refraction_strength : hint_range(0.0, 0.1, 0.0001) = 0.05;
uniform float normal_map_refraction_strength : hint_range(0.0, 1., 0.01) = 0.5;

uniform float foam_distance : hint_range(0.0, 20.0, 0.01) = 10.0;
uniform sampler2D foam_gradient : hint_default_white;
uniform sampler2D foam_normal_map : hint_normal, filter_linear_mipmap, repeat_enable;

const float g = 9.81;

float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

float jonswap(float omega, float jon_wind_speed, float jon_fetch) {
	float omega_p = 22.0 * pow((g*g) / (jon_wind_speed * jon_fetch), 1.0/3.0);
	 omega_p = max(omega_p, 0.001); // guard against 0
	float alpha = 0.076 * pow((g / (jon_wind_speed*jon_wind_speed)) * jon_fetch, -0.22);
	float gamma = 3.3;
	float sigma = omega <= omega_p ? 0.07 : 0.09;
	float diff = (omega - omega_p);
	float r = exp(-(diff*diff) / (2.0 * sigma*sigma * omega_p*omega_p));
	return (alpha * g*g / pow(omega, 5.0)) * exp(-1.25 * pow(omega_p/omega, 4.0)) * pow(gamma, r);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 derivative = vec2(0.0);

	vec3 gerstner = vec3(0.0);
	float delta_omega = omega_range / float(wave_count - 1);

	for (int i = 0; i < wave_count; i++) {
		float f = float(i);
		float omega = omega_min + float(i) * delta_omega;
		float energy = jonswap(omega, 10.0, 100000.0);
		float amplitude = sqrt(2.0 * energy * delta_omega);
		float wavelength = 2.0 * PI * g / (omega*omega);

		float angle = hash(f + seed) * PI * 2.0;
		vec2 rand_dir = vec2(cos(angle), sin(angle));
		vec2 dir = normalize(mix(wind_dir, rand_dir, spread));
        
		//float freq = base_frequency * pow(fbm_frequency, f);
		//float amp = base_amplitude * pow(fbm_amplitude, f);
        float phase = hash(f + 0.5 + seed) * PI * 2.0;
        
		float k = (2.0 * PI) / wavelength;
		float wave_val = dot(dir, world_position.xz) * k + TIME * omega + phase;

		gerstner.x += base_steepness * amplitude * dir.x * cos(wave_val);
		gerstner.z += base_steepness * amplitude * dir.y * cos(wave_val);
		gerstner.y += amplitude * sin(wave_val);

		derivative += amplitude * wavelength * cos(wave_val) * dir;
		VERTEX.y += gerstner.y;
	}
	//VERTEX.xyz += gerstner;
	// normal from derivative: flat plane normal (0,1,0) perturbed by slope
	wave_normal = normalize(vec3(-derivative.x, 1.0, -derivative.y));
}

void fragment() {
	float omega_p = 22.0 * pow((g*g) / (wind_speed * fetch), 1.0/3.0);
	ALBEDO = vec3(omega_p / 5.0);
	//ROUGHNESS = roughness; //1.0 - fresnel * roughness;
//
	//vec3 nm = texture(normal_map_1, world_position.xz * normal_scale).rgb;
	//NORMAL = (VIEW_MATRIX * vec4(wave_normal, 0.0)).xyz;
	//NORMAL_MAP = nm;
	//NORMAL_MAP_DEPTH = normal_depth;
	//nm = nm * 2.0 - 1.0; // convert to -1.0 to 1.0 for refraction UVs
//
	//// get refracted UVs
	//vec2 ref_ofs = clamp(SCREEN_UV - (NORMAL.xy - nm.xy * normal_map_refraction_strength) * refraction_strength, 0.0, 1.0);
	//float ref_depth = textureLod(depth_texture, ref_ofs, 0).r;
	//vec4 ref_world = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, ref_depth, 1.0);
	//ref_world.xyz /= ref_world.w;
//
	//// if refracted sample is in front of water surface, fall back to unrefracted
	//vec2 final_uv = clamp(ref_world.z > VERTEX.z ? SCREEN_UV : ref_ofs, vec2(0.0), vec2(1.0));
//
	//float depth = texture(depth_texture, SCREEN_UV, 0).r;
	//float ref_depth_final = texture(depth_texture, final_uv, 0).r;
//
	//vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	//vec3 ndc_ref = vec3(final_uv * 2.0 - 1.0, ref_depth_final);
	//
	//vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	//view_pos.xyz /= view_pos.w;
//
	//vec4 view_pos_ref = INV_PROJECTION_MATRIX * vec4(ndc_ref, 1.0);
	//view_pos_ref.xyz /= view_pos_ref.w;
//
	//// Scene geometry in view space (you already have this)
	//vec3 scene_view_pos = view_pos.xyz;
	//vec3 scene_view_pos_ref = view_pos_ref.xyz;
//
	//// Water surface is just VERTEX (already view space)
	//vec3 water_view_pos = VERTEX;
	//vec3 water_view_pos_ref = VERTEX;
//
	//// 3D distance through water
	//float dist = distance(scene_view_pos, water_view_pos);
	//float dist_ref = distance(scene_view_pos_ref, water_view_pos_ref);
//
	//vec3 absorption = absorption_coeffs * absorption_density;
	//vec3 transmitted = exp(-dist_ref * absorption);
//
	//float foam = 1.0 - smoothstep(0.0, foam_distance, dist);
//
	//float foam_val = texture(foam_gradient, world_position.xz * 1.0).r;
	//vec3 foam_norm = texture(foam_normal_map, world_position.xz * 1.0).rgb;
	//foam_val = foam_val * foam * 0.3;
//
	//vec3 screen_color = texture(screen_texture, final_uv).rgb;
	//
	//ALBEDO = clamp(mix(screen_color * transmitted, water_color.rgb, 1.0 - transmitted) + foam_val, 0.0, 1.0);
	//ALPHA = clamp(dist * dist * alpha_fade_distance, 0.0, 1.0);
}

//void light() {
	//// Called for every pixel for every light affecting the material.
	//// Uncomment to replace the default light processing function with this one.
//}
