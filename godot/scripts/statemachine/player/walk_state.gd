extends State

@export var idle_state: State
@export var sprint_state: State
@export var jump_state: State

var player: Player

func initialize(state_machine: StateMachine) -> void:
	super.initialize(state_machine)

	player = state_machine.parent as Player

func physics_tick(delta: float) -> State:
	var input_vector: Vector2 = player.input_vector

	if input_vector.length() < 0.2:
		return idle_state

	if Input.is_action_pressed("sprint"):
		return sprint_state

	player.move(delta, player.walk_speed, player.acceleration)

	return null

func input_tick(event: InputEvent) -> State:
	if event.is_action_pressed("jump"):
		return jump_state

	return null
