extends Node2D
class_name WorldBounds
## Central bounds for wrapping, spawning, and placing level content.
##
## Zones (left → right):
##   [min_x] hard world edge
##   [left_trigger] player wrap begins
##   [safe_spawn_min_x] safe placement for props/items/NPCs/art
##   ... playable spawn band ...
##   [safe_spawn_max_x]
##   [right_trigger] player wrap begins
##   [max_x] hard world edge

@export var min_x := -1520.0
@export var max_x := 2480.0
@export var wrap_inset := 24.0
## How far inside each world edge before the player wraps.
@export var wrap_trigger_margin := 480.0
## Extra inset inside wrap triggers for static spawns (items, NPCs, art).
@export var spawn_edge_padding := 80.0
## Default minimum gap between a new spawn and existing spawn_avoid nodes.
@export var default_spawn_separation := 200.0
@export var spawn_placement_attempts := 24


func _ready() -> void:
	add_to_group("world_bounds")


static func get_instance(from_node: Node) -> WorldBounds:
	return from_node.get_tree().get_first_node_in_group("world_bounds") as WorldBounds


func get_width() -> float:
	return max_x - min_x


func get_left_trigger() -> float:
	return min_x + wrap_trigger_margin


func get_right_trigger() -> float:
	return max_x - wrap_trigger_margin


func get_safe_spawn_min_x() -> float:
	return get_left_trigger() + spawn_edge_padding


func get_safe_spawn_max_x() -> float:
	return get_right_trigger() - spawn_edge_padding


func is_within_safe_spawn_x(x: float) -> bool:
	return x >= get_safe_spawn_min_x() and x <= get_safe_spawn_max_x()


func clamp_spawn_x(x: float) -> float:
	return clampf(x, get_safe_spawn_min_x(), get_safe_spawn_max_x())


func get_avoid_x_positions(extra_positions: Array[float] = []) -> Array[float]:
	var avoid_positions: Array[float] = extra_positions.duplicate()

	var player := get_tree().get_first_node_in_group("player")
	if player is Node2D:
		avoid_positions.append(player.global_position.x)

	for node in get_tree().get_nodes_in_group("quest_npcs"):
		if node is Node2D:
			avoid_positions.append(node.global_position.x)

	for node in get_tree().get_nodes_in_group("spawn_avoid"):
		if node is Node2D and node != self:
			avoid_positions.append(node.global_position.x)

	return avoid_positions


func random_safe_spawn_x(
	avoid_x_positions: Array[float] = [],
	min_separation: float = -1.0
) -> float:
	if min_separation < 0.0:
		min_separation = default_spawn_separation

	var spawn_min := get_safe_spawn_min_x()
	var spawn_max := get_safe_spawn_max_x()
	if spawn_min >= spawn_max:
		return (spawn_min + spawn_max) * 0.5

	for _attempt in spawn_placement_attempts:
		var x := randf_range(spawn_min, spawn_max)
		if _is_far_enough_from(x, avoid_x_positions, min_separation):
			return x

	return randf_range(spawn_min, spawn_max)


func random_safe_spawn_position(
	y: float,
	avoid_x_positions: Array[float] = [],
	min_separation: float = -1.0
) -> Vector2:
	var x := random_safe_spawn_x(avoid_x_positions, min_separation)
	return Vector2(x, y)


func place_node_at_safe_random(
	node: Node2D,
	y: float,
	avoid_x_positions: Array[float] = [],
	min_separation: float = -1.0
) -> void:
	var combined_avoid := get_avoid_x_positions(avoid_x_positions)
	node.global_position = random_safe_spawn_position(y, combined_avoid, min_separation)


func clamp_node_spawn_x(node: Node2D) -> void:
	var pos := node.global_position
	pos.x = clamp_spawn_x(pos.x)
	node.global_position = pos


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


func wrap_position(pos: Vector2) -> Vector2:
	pos.x = wrap_x(pos.x)
	return pos


func _is_far_enough_from(x: float, avoid_positions: Array[float], min_separation: float) -> bool:
	for avoid_x in avoid_positions:
		if absf(x - avoid_x) < min_separation:
			return false
	return true
