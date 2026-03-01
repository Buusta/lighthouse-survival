class_name State extends Node

var parent: Node

func initialize(par: Node) -> void:
	parent = par

func tick(_delta: float) -> State:
	return null

func physics_tick(_delta: float) -> State:
	return null

func input_tick(_event: InputEvent) -> State:
	return null

func exit() -> void:
	pass

func enter() -> void:
	pass
