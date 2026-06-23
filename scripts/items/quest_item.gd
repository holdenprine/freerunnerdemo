extends Area2D
## Quest item picked up when the player walks into it.

@export var min_spawn_separation := -1.0

@onready var visual: ColorRect = $Visual

var _world_bounds: WorldBounds


func _ready() -> void:
	add_to_group("spawn_avoid")
	body_entered.connect(_on_body_entered)
	_world_bounds = get_parent() as WorldBounds
	_place_at_random_safe_position()


func _place_at_random_safe_position() -> void:
	if _world_bounds == null:
		return

	var separation := min_spawn_separation
	if separation < 0.0:
		separation = _world_bounds.default_spawn_separation

	_world_bounds.place_node_at_safe_random(self, global_position.y, [], separation)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameState.has_quest_item or GameState.quest_completed:
		return

	GameState.pick_up_quest_item()
	queue_free()
