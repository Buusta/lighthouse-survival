class_name KeyboardInputComponent extends Node

@export var active: bool = false

var input_vector: Vector2

signal jump()
signal exit()
signal dev_console()



func _process(_delta: float) -> void:
	if not active:
		return

	input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_dev_console"):
		get_viewport().set_input_as_handled()
		dev_console.emit()

func _unhandled_input(event: InputEvent) -> void:

	input_vector = Vector2(0.0, 0.0)

	if event.is_action_pressed("exit"):
		exit.emit()

	if not active:
		return

	input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if event.is_action_pressed("jump"):
		jump.emit()
