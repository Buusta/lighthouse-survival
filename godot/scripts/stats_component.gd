class_name PlayerStatsComponent extends Node

@export_category("Stats")
@export var base_hunger: float = 100.0
@export var hunger_decay_rate: float = 5.0
@export var base_thirst: float = 100.0
@export var thirst_decay_rate: float = 10.0

@onready var hunger: float = base_hunger
@onready var thirst: float = base_thirst

var stats_draining: bool = true

func _ready() -> void:
	DevConsole.add_command("reset_stats", _reset_stats)
	DevConsole.add_command("stats_draining", _stats_draining, 1)

func _process(delta: float) -> void:
	_update_stats(delta)

func _update_stats(delta: float) -> void:
	if stats_draining:
		hunger -= hunger_decay_rate * delta / 60.0
		thirst -= thirst_decay_rate * delta / 60.0

### COMMANDS ###

func _stats_draining(args: PackedStringArray) -> bool:
	var new_draining: bool = true if int(args[0]) == 1 else false
	stats_draining = new_draining
	return new_draining

func _reset_stats(_args: PackedStringArray) -> String:
	hunger = base_hunger
	thirst = base_thirst
	return "reset"
