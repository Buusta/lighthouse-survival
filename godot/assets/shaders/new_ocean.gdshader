shader_type spatial;
render_mode cull_disabled, depth_draw_always;

uniform float seed = 42.0;
uniform float wind_speed = 10.0;
uniform float fetch = 100000.0;
uniform float omega_min = 0.5;
uniform float omega_max = 5.0;
uniform int wave_count = 8;
uniform sampler2D sample_data : filter_nearest;
uniform float amplitude_scale = 1.0;
uniform float frequency_scale = 1.0;
uniform float base_steepness : hint_range(0.0, 5.0) = 0.5;
uniform vec2 wind_dir = vec2(1.0, 0.0);
uniform float spread : hint_range(0.0, 1.0) = 0.5;

const float g = 9.81;
const float epsilon = .00001;

varying vec3 wave_normal;
varying vec3 world_position;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;

uniform vec3 water_color : source_color = vec3(0.0, 0.3, 0.5);
uniform float alpha_fade_distance : hint_range(0.0, 8.0, 0.001) = 3.0;
uniform vec3 absorption_coeffs : source_color = vec3(0.0, 0.3, 0.5);
uniform float absorption_density : hint_range(0.0, 1.0, 0.001) = 0.2;

uniform float roughness : hint_range(0.0, 1.0, 0.001) = 0.05;
uniform float specular : hint_range(0.0, 1.0, 0.001) = 0.40;

uniform float foam_distance : hint_range(0.0, 20.0, 0.01) = 10.0;
uniform sampler2D foam_gradient : hint_default_white;
uniform sampler2D foam_normal_map : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D normal_map_1 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_map_2 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale = 0.5;
uniform float normal_velocity = 0.5;
uniform float normal_scale_2 = 0.5;
uniform float normal_velocity_2 = 0.5;
uniform float normal_strength_1 = 0.5;
uniform float normal_strength_2 = 0.5;
uniform float normal_balance : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float normal_depth : hint_range(-1.0, 1.0, 0.001) = -.05;

uniform float refraction_strength : hint_range(0.0, 0.1, 0.0001) = 0.05;
uniform float normal_map_refraction_strength = 0.25;

float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

float jonswap(float jon_omega, float jon_wind_speed, float jon_fetch) {
	float omega_p = 22.0 * pow((g*g) / (jon_wind_speed * jon_fetch), 1.0/3.0);
	 omega_p = max(omega_p, 0.001); // guard against 0
	float alpha = 0.076 * pow((g / (jon_wind_speed*jon_wind_speed)) * jon_fetch, -0.22);
	float gamma = 3.3;
	float sigma = jon_omega <= omega_p ? 0.07 : 0.09;
	float denom = 2.0 * sigma*sigma * omega_p*omega_p;
	float diff = jon_omega - omega_p;
	float r = exp(-(diff*diff) / max(denom, 1e-6));
	return (alpha * g*g / pow(jon_omega, 5.0)) * exp(-1.25 * pow(omega_p/jon_omega, 4.0)) * pow(gamma, r);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float delta_omega = (omega_max - omega_min) / float(wave_count - 1);

	vec3 gerstner = vec3(0.0);
	vec2 derivative = vec2(0.0);

	for(int i = 0; i < wave_count; i++) {
		float f = float(i);
		float t = f / float(wave_count - 1);
		float omega = omega_min + f * delta_omega;
		//float amplitude = texture(sample_data, vec2(t,0.0)).r * amplitude_scale;
		float energy = jonswap(omega, wind_speed, fetch);
		//float amplitude = sqrt(2.0 * energy) * amplitude_scale;
		float k = frequency_scale * omega * omega / g;

		float angle_offset = (hash(f + seed) * 2.0 - 1.0) * PI * spread;
		float base_angle = atan(wind_dir.y, wind_dir.x);
		float angle = base_angle + angle_offset;
		vec2 dir = vec2(cos(angle), sin(angle));

		// then weight amplitude by direction alignment:
		float dir_weight = pow(max(0.0, dot(dir, normalize(wind_dir))), 2.0 / max(spread, 0.001));
		float amplitude = clamp(sqrt(2.0 * energy * delta_omega) * amplitude_scale * dir_weight, 0.0, 25.0);

		float phase = hash(PI * 2.0 * seed);
		float wave_val = dot(dir, world_position.xz) * k + TIME * omega + phase;
		
		float steepness = base_steepness / (k * float(wave_count));
		gerstner.x += base_steepness * amplitude * dir.x * cos(wave_val);
		gerstner.z += base_steepness * amplitude * dir.y * cos(wave_val);
		gerstner.y += amplitude * sin(wave_val);

		derivative += amplitude * k * cos(wave_val) * dir;
		}

	VERTEX += gerstner;
	wave_normal = normalize(vec3(-derivative.x, 1.0, -derivative.y));
}

//void fragment() {
    //float t = 0.5; // sample middle of texture
    //vec4 sample = texture(sample_data, vec2(t, 0.5));
    //ALBEDO = vec3(sample.g * 10000.0);
//}

void fragment() {
	ROUGHNESS = roughness;
	METALLIC = 0.0;
	SPECULAR = specular;

	vec3 nm = texture(normal_map_1, world_position.xz * normal_scale + wind_dir * TIME * normal_velocity).rgb;
	nm = mix(nm, vec3(0.5, 0.5, 1.0), 1.0 - normal_strength_1);
	vec3 nm2 = texture(normal_map_2, world_position.xz * normal_scale_2 + wind_dir * TIME * normal_velocity_2).rgb;
	nm2 = mix(nm2, vec3(0.5, 0.5, 1.0), 1.0 - normal_strength_2);
	NORMAL = (VIEW_MATRIX * vec4(wave_normal, 0.0)).xyz;
	NORMAL_MAP = mix(nm, nm2, normal_balance);
	NORMAL_MAP_DEPTH = normal_depth;
	nm = nm * 2.0 - 1.0; // convert to -1.0 to 1.0 for refraction UVs

	float fresnel = pow(1.0 - clamp(dot(normalize((NORMAL)), normalize(VIEW)), 0.0, 1.0), 10.0);
	fresnel = mix(0.02, 1.0, fresnel); // Schlick approximation

	// get refracted UVs
	vec2 ref_ofs = clamp(SCREEN_UV - (NORMAL.xy - nm.xy * normal_map_refraction_strength) * refraction_strength, 0.0, 1.0);
	float ref_depth = textureLod(depth_texture, ref_ofs, 0).r;
	vec4 ref_world = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, ref_depth, 1.0);
	ref_world.xyz /= ref_world.w;

	// if refracted sample is in front of water surface, fall back to unrefracted
	vec2 final_uv = clamp(ref_world.z > VERTEX.z ? SCREEN_UV : ref_ofs, vec2(0.0), vec2(1.0));

	float depth = texture(depth_texture, SCREEN_UV, 0).r;
	float ref_depth_final = texture(depth_texture, final_uv, 0).r;

	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec3 ndc_ref = vec3(final_uv * 2.0 - 1.0, ref_depth_final);
	
	vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view_pos.xyz /= view_pos.w;

	vec4 view_pos_ref = INV_PROJECTION_MATRIX * vec4(ndc_ref, 1.0);
	view_pos_ref.xyz /= view_pos_ref.w;

	// Scene geometry in view space (you already have this)
	vec3 scene_view_pos = view_pos.xyz;
	vec3 scene_view_pos_ref = view_pos_ref.xyz;

	// Water surface is just VERTEX (already view space)
	vec3 water_view_pos = VERTEX;
	vec3 water_view_pos_ref = VERTEX;

	// 3D distance through water
	float dist = distance(scene_view_pos, water_view_pos);
	float dist_ref = distance(scene_view_pos_ref, water_view_pos_ref);

	vec3 absorption = absorption_coeffs * absorption_density;
	vec3 transmitted = exp(-dist_ref * absorption);

	float foam = 1.0 - smoothstep(0.0, foam_distance, dist);

	float foam_val = texture(foam_gradient, world_position.xz * 1.0).r;
	vec3 foam_norm = texture(foam_normal_map, world_position.xz * 1.0).rgb;
	foam_val = foam_val * foam * 0.3;

	vec3 screen_color = texture(screen_texture, final_uv).rgb;
	
	ALBEDO = clamp(mix(screen_color * transmitted, water_color.rgb, 1.0 - transmitted) + foam_val, 0.0, 1.0);
	ALPHA = clamp(dist * dist * alpha_fade_distance, 0.0, 1.0);
	METALLIC = 0.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
