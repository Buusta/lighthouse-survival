extends State

var player: Player

func initialize(state_machine: StateMachine) -> void:
	super.initialize(state_machine)

	player = state_machine.parent as Player

func enter() -> void:
	player.jump()
