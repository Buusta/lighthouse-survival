class_name StateComposite extends State

@export var base_state: State
var current_state: State

func initialize(par: Node) -> void:
	parent = par

	for sub_state: State in get_children():
		sub_state.initialize(parent)

func _change_state(new_state: State) -> void:
	if new_state == current_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()

func tick(delta: float) -> State:
	var return_state: State = current_state.tick(delta)

	if return_state:
		_change_state(return_state)

	return null

func physics_tick(delta: float) -> State:
	var return_state: State = current_state.physics_tick(delta)

	if return_state:
		_change_state(return_state)

	return null

func input_tick(event: InputEvent) -> State:
	var return_state: State = current_state.input_tick(event)

	if return_state:
		_change_state(return_state)

	return null

func exit() -> void:
	current_state.exit()
	current_state = null
	pass

func enter() -> void:
	current_state = base_state
	current_state.enter()
	pass
