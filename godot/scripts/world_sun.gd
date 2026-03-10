@tool
extends DirectionalLight3D

@export var base_light_energy: float = 1.0

func _process(_delta: float) -> void:
	light_energy = get_sun_energy()

func get_sun_energy() -> float:
	var zenith_angle: float = global_basis.z.dot(Vector3.UP) # adjust axis to match your setup
	var sun_fade: float = 1.0 - clamp(1.0 - exp(global_basis.z.y), 0.0, 1.0)
	return max(0.0, 0.757 * zenith_angle) * base_light_energy * sun_fade
