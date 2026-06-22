extends Node2D
class_name WorldBounds
## Defines the horizontal play space and preemptively wraps before the camera hits an edge.

@export var min_x := -1520.0
@export var max_x := 2480.0
@export var wrap_inset := 24.0
## How far inside each world edge (in pixels) before the player wraps.
## Tune this on the World node in the Inspector. Default 480 = half of a 960px-wide view.
@export var wrap_trigger_margin := 480.0


func _ready() -> void:
	add_to_group("world_bounds")


func get_width() -> float:
	return max_x - min_x


func get_left_trigger() -> float:
	return min_x + wrap_trigger_margin


func get_right_trigger() -> float:
	return max_x - wrap_trigger_margin


func should_wrap_x(x: float) -> bool:
	return x < get_left_trigger() or x >= get_right_trigger()


func wrap_x(x: float) -> float:
	var left_trigger := get_left_trigger()
	var right_trigger := get_right_trigger()

	if x < left_trigger:
		var overflow := left_trigger - x
		return right_trigger - overflow
	if x >= right_trigger:
		var overflow := x - right_trigger
		return left_trigger + overflow
	return x


func wrap_position(position: Vector2) -> Vector2:
	position.x = wrap_x(position.x)
	return position
