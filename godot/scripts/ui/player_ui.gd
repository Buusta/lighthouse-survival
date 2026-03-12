class_name PlayerUI extends CanvasLayer

@onready var frame_time_label: Label = $FpsLabel
@onready var dev_console: Control = $DevConsole
@onready var inventory: Control = $Inventory

@onready var thirst_bar: ProgressBar = $ThirstBar
@onready var hunger_bar: ProgressBar = $HungerBar

@export var keybouard_input_component: KeyboardInputComponent

var frame_count: int = 0
var avg_delta: float = 0.0

func _ready() -> void:
	DevConsole.add_command("show_fps", _toggle_fps, 1)

func _process(delta: float) -> void:
	if Time.get_ticks_msec() / 2000.0 > 1.0:
		frame_count += 1
		frame_count = min(frame_count, 240)
		avg_delta += (delta - avg_delta) / frame_count

		frame_time_label.text = "ms: %.2f | avg: %.2f | fps: %d" % [delta * 1000.0, avg_delta * 1000.0, int(1.0 / avg_delta)]

		_update_stats_bar()

func _update_stats_bar() -> void:
	hunger_bar.value = GameLocator.player.stats.hunger
	thirst_bar.value = GameLocator.player.stats.thirst

func _toggle_dev_console() -> void:
	if dev_console.visible:
		dev_console.visible = false
		keybouard_input_component.active = true
	else:
		dev_console.visible = true
		keybouard_input_component.active = false

func _toggle_inventory() -> void:
	if inventory.visible:
		inventory.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		inventory.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _toggle_fps(args: PackedStringArray) -> bool:
	var toggle: bool = true if int(args[0]) == 1 else false
	frame_time_label.visible = toggle
	return toggle
