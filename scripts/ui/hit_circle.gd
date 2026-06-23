extends Control
class_name HitCircle
## Single hit-point indicator: red fill with black border.

const FILL_COLOR := Color(0.9, 0.15, 0.15)
const BORDER_COLOR := Color.BLACK
const BORDER_WIDTH := 2.0

var is_filled := true:
	set(value):
		is_filled = value
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(28, 28)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.5 - BORDER_WIDTH

	if is_filled:
		draw_circle(center, radius, FILL_COLOR)
	draw_arc(center, radius, 0.0, TAU, 32, BORDER_COLOR, BORDER_WIDTH, true)
