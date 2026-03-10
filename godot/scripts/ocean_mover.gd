extends Node

@export var target_position: Node3D
@export var ocean: Node3D
@export var step_size: float = 4.4	
@export var follow_y: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if target_position && ocean:
		if not ocean.global_position.x == snapped(target_position.global_position.x, step_size) or not ocean.global_position.z == snapped(target_position.global_position.z, step_size):
			ocean.global_position.x = snapped(target_position.global_position.x, step_size)
			ocean.global_position.z = snapped(target_position.global_position.z, step_size)

			if follow_y:
				ocean.global_position.y = snapped(target_position.global_position.y, step_size)
