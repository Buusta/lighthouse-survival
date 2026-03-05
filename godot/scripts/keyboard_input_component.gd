class_name KeyboardInputComponent extends Node

@export var active: bool = false

var input_vector: Vector2

signal jump()
signal exit()



func _process(_delta: float) -> void:
	if not active:
		return

	input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if event.is_action_pressed("jump"):
		jump.emit()

	if event.is_action_pressed("exit"):
		exit.emit()
