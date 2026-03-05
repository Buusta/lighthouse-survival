shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled, diffuse_burley;

uniform sampler2D albedo: source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normal_map: hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D roughness: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D transmission: filter_linear_mipmap_anisotropic, repeat_enable;

uniform float transmittance_strength: hint_range(0.0, 10.0, 0.01) = 1.0;
uniform float transmittance_depth: hint_range(0.0, 10.0, 0.01) = 1.0;
uniform float transmittance_boost: hint_range(0.0, 10.0, 0.01) = 1.0;
uniform float alpha_mut : hint_range(0.0, 10.0, 0.01) = 1.0;

// Wind uniforms
uniform float wind_frequency : hint_range(0.0, 100.0, 0.01) = 0.1;
uniform vec3 wind_direction = vec3(1.0, 0.0, 0.0);
uniform float wind_speed : hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float wind_amount : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float detail_freq : hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float detail_amp : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float branch_amp : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float bend_scale : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float trunk_bend_amount : hint_range(0.0, 0.01, 0.0001) = 0.005;
uniform float trunk_bend_speed : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float trunk_bend_offset : hint_range(0.0, 0.01, 0.0001) = 0.005;

// Crysis smooth triangle wave helpers
vec4 SmoothCurve(vec4 x) { return x * x * (3.0 - 2.0 * x); }
vec4 TriangleWave(vec4 x) { return abs(fract(x + 0.5) * 2.0 - 1.0); }
vec4 SmoothTriangleWave(vec4 x) { return SmoothCurve(TriangleWave(x)); }

void vertex() {
	// Vertex colors from your painted mesh
	float edge_stiffness = COLOR.r;   // R: edge flutter
	float leaf_phase_var = COLOR.g;   // G: per-leaf phase
	float leaf_stiffness = COLOR.b;   // B: overall leaf bend
	// COLOR.a is AO, used in fragment

	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// --- Detail bending (leaves) ---
	float obj_phase = dot(world_pos, vec3(1.0));
	float branch_phase = obj_phase + leaf_phase_var;
	float vtx_phase = dot(VERTEX, vec3(leaf_stiffness + branch_phase, 0.0, 0.0));

	vec2 waves_in = TIME * wind_speed + vec2(vtx_phase, branch_phase);
	vec4 waves = (fract(waves_in.xxyy * vec4(1.975, 0.793, 0.375, 0.193)) * 2.0 - 1.0)
	                * wind_speed * detail_freq;
	waves = SmoothTriangleWave(waves);
	vec2 waves_sum = waves.xz + waves.yw;

	// Edge bending along normal XY, branch bending along Z
	VERTEX.xy += waves_sum.xx * edge_stiffness * detail_amp * NORMAL.xy;
	VERTEX.z  += waves_sum.y  * leaf_stiffness * branch_amp;

	// --- Main bending (whole tree sway) ---
	float bf = VERTEX.z * bend_scale;
	bf += 1.0;
	bf *= bf;
	bf = bf * bf - bf;
	vec3 new_pos = VERTEX;
	new_pos.xy += wind_direction.xy * bf * wind_amount;
	float len = length(VERTEX);
	VERTEX = normalize(new_pos) * len;

	vec3 world_origin = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float trunk_phase = dot(world_origin, normalize(wind_direction)) * wind_frequency;
	float wave = sin(TIME * trunk_bend_speed + trunk_phase);
	vec2 xz_displacement = (wind_direction.xz * trunk_bend_amount * wave + wind_direction.xz * trunk_bend_offset) * VERTEX.y * VERTEX.y * VERTEX.y;
	VERTEX.xz += xz_displacement;
	VERTEX.y -= dot(xz_displacement, xz_displacement) * 0.5;
}

void fragment() {
	vec4 albedo_tex = texture(albedo, UV);
	vec4 normal_tex = texture(normal_map, UV);
	vec4 roughness_tex = texture(roughness, UV);
	vec4 transmission_tex = texture(transmission, UV);

	ALBEDO = albedo_tex.rgb * COLOR.a;
	ALPHA = clamp(albedo_tex.a * alpha_mut, 0.0, 1.0);

	ROUGHNESS = roughness_tex.r;

	NORMAL_MAP = normal_tex.rgb;

	SSS_TRANSMITTANCE_COLOR = transmission_tex.rgba;
	SSS_STRENGTH = transmittance_strength;
	SSS_TRANSMITTANCE_DEPTH = transmittance_depth;
	SSS_TRANSMITTANCE_BOOST = transmittance_boost;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
