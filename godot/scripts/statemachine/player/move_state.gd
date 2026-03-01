extends State

@export var idle_state: State
@export var sprint_state: State

var player_par: Player

func initialize(par: Node) -> void:
	super.initialize(par)

	player_par = par as Player

func enter() -> void:
	print("moving")

func physics_tick(_delta: float) -> State:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if input_vector.length() < 0.2:
		return idle_state

	if Input.is_action_pressed("sprint"):
		return sprint_state

	player_par.move(player_par.walk_speed)

	return null
