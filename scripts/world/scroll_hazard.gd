extends Area2D
class_name MovingHazard
## Hazard that moves horizontally and wraps with the world loop.

@export var move_speed := 220.0
@export var despawn_distance := 1200.0

var _move_direction := -1.0
var _spawn_position := Vector2.ZERO
var _world_bounds: Node2D


func setup(move_direction: float) -> void:
	_move_direction = move_direction
	_spawn_position = global_position


func _ready() -> void:
	body_entered.connect(_handle_body_entered)
	_world_bounds = get_tree().get_first_node_in_group("world_bounds")


func _physics_process(delta: float) -> void:
	if not GameState.is_playing or GameState.is_dialog_open:
		return

	position.x += _move_direction * move_speed * delta
	if _world_bounds and _world_bounds.should_wrap_x(global_position.x):
		global_position = _world_bounds.wrap_position(global_position)

	if global_position.distance_to(_spawn_position) > despawn_distance:
		queue_free()


func _handle_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		on_player_hit(body)


## Override in subclasses to define what happens when the player is hit.
func on_player_hit(_body: Node2D) -> void:
	GameState.end_run()
