extends StateComposite

func physics_tick(delta: float) -> State:
	condition()

	return super.physics_tick(delta)

func condition() -> State:
	return null
