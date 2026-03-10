shader_type spatial;

uniform float fetch = 100000.0;
uniform float wind_speed = 10.0;

uniform float energy_multiplier = 1.0;
uniform float omega = 1.5;

const float g = 9.81;

float jonswap(float jon_omega, float jon_wind_speed, float jon_fetch) {
	float omega_p = 22.0 * pow((g*g) / (jon_wind_speed * jon_fetch), 1.0/3.0);
	 omega_p = max(omega_p, 0.001); // guard against 0
	float alpha = 0.076 * pow((g / (jon_wind_speed*jon_wind_speed)) * jon_fetch, -0.22);
	float gamma = 3.3;
	float sigma = jon_omega <= omega_p ? 0.07 : 0.09;
	float r = exp(-pow(jon_omega - omega_p, 2.0) / (2.0 * sigma*sigma * omega_p*omega_p));
	return (alpha * g*g / pow(jon_omega, 5.0)) * exp(-1.25 * pow(omega_p/jon_omega, 4.0)) * pow(gamma, r);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float energy = jonswap(omega, wind_speed, fetch) * energy_multiplier;
	vec3 color = clamp(mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), energy), vec3(0.0), vec3(1.0));
	ALBEDO = vec3(color);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
