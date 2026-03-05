extends State

var player: Player

func initialize(state_machine: StateMachine) -> void:
	super.initialize(state_machine)

	player = state_machine.parent as Player

func physics_tick(delta: float) -> State:
	var input_vector: Vector2 = player.input_vector

	if input_vector.length() >= 0.2:
		player.move(delta, player.air_velocity, player.air_acceleration)
	else:
		player.move(delta, 0.0, player.air_deceleration)

	return null
