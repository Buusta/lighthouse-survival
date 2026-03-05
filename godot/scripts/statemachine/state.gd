class_name State extends Node

var parent: StateMachine

func initialize(state_machine: StateMachine) -> void:
	parent = state_machine

func tick(_delta: float) -> State:
	return null

func physics_tick(_delta: float) -> State:
	return null

func input_tick(_event: InputEvent) -> State:
	return null

func exit() -> void:
	if parent.debug_enabled:
		print("[%.3f] %s - %s" % [Time.get_ticks_msec() / 1000.0, name, "exit"])

func enter() -> void:
	if parent.debug_enabled:
		print("[%.3f] %s - %s" % [Time.get_ticks_msec() / 1000.0, name, "enter"])
