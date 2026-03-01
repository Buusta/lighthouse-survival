extends State

@export var walk_state: State

var player_par: Player

func initialize(par: Node) -> void:
	super.initialize(par)

	player_par = par as Player

func enter() -> void:
	print("idling")
	player_par.velocity = Vector3(0.0, player_par.velocity.y, 0.0)

func input_tick(_event: InputEvent) -> State:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if input_vector.length() >= 0.2:
		return walk_state

	return null
