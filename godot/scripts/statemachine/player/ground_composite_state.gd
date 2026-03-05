extends StateComposite

@export var air_composite_state: StateComposite

var player: Player

func initialize(state_machine: StateMachine) -> void:
	super.initialize(state_machine)

	player = state_machine.parent as Player

func physics_tick(delta: float) -> State:
	var return_state: State = condition()

	if return_state:
		return return_state

	return super.physics_tick(delta)

func condition() -> State:
	if player.is_on_floor():
		return null

	current_state = base_state

	return air_composite_state
