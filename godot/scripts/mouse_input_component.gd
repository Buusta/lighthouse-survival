class_name MouseInputComponent extends Node

@export var active: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
