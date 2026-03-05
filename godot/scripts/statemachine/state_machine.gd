class_name StateMachine extends Node

@export var current_state: State
@export var debug_enabled: bool = false
@onready var parent: Node = get_parent()

func _ready() -> void:
	for sub_state: State in get_children():
		sub_state.initialize(self)

	current_state.enter()

func _change_state(new_state: State) -> void:
	if new_state == current_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()

func _process(delta: float) -> void:
	var return_state: State = current_state.tick(delta)

	if return_state:
		_change_state(return_state)

func _physics_process(delta: float) -> void:
	var return_state: State = current_state.physics_tick(delta)

	if return_state:
		_change_state(return_state)

func _unhandled_input(event: InputEvent) -> void:
	var return_state: State = current_state.input_tick(event)

	if return_state:
		_change_state(return_state)
