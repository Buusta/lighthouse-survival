extends CanvasLayer

@onready var frame_time_label: Label = $FpsLabel

var frame_count: int = 0
var avg_delta: float = 0.0

func _process(delta: float) -> void:
	if Time.get_ticks_msec() / 2000.0 > 1.0:
		frame_count += 1
		frame_count = min(frame_count, 240)
		avg_delta += (delta - avg_delta) / frame_count

		frame_time_label.text = "ms: %.2f | avg: %.2f | fps: %d" % [delta * 1000.0, avg_delta * 1000.0, int(1.0 / avg_delta)]
