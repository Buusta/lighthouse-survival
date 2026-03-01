extends State

@export var idle_state: State
@export var walk_state: State

var player_par: Player

func initialize(par: Node) -> void:
	super.initialize(par)

	player_par = par as Player

func enter() -> void:
	print("ZOOOMIESSS")

func physics_tick(_delta: float) -> State:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if input_vector.length() < 0.2:
		return idle_state

	if not Input.is_action_pressed("sprint"):
		return walk_state

	player_par.move(player_par.sprint_speed)

	return null
