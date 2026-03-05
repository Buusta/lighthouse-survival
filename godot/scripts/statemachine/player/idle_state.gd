extends State

@export var walk_state: State
@export var jump_state: State

var player: Player

func initialize(state_machine: StateMachine) -> void:
	super.initialize(state_machine)

	player = state_machine.parent as Player

func physics_tick(delta: float) -> State:
	var input_vector: Vector2 = player.input_vector

	if input_vector.length() >= 0.2:
		return walk_state

	player.move(delta, 0.0, player.deceleration)

	return null

func input_tick(event: InputEvent) -> State:
	if event.is_action_pressed("jump"):
		return jump_state

	return null
	
