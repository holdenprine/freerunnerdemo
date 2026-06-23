extends Node2D
class_name SafeSpawned
## Attach to editor-placed content so it is clamped into the safe spawn band on load.
## Add nodes to the spawn_avoid group to keep random spawns away from them.

@export var clamp_on_ready := true
@export var register_as_spawn_avoid := true


func _ready() -> void:
	if register_as_spawn_avoid and not is_in_group("spawn_avoid"):
		add_to_group("spawn_avoid")

	if not clamp_on_ready:
		return

	var bounds := get_tree().get_first_node_in_group("world_bounds") as WorldBounds
	if bounds:
		bounds.clamp_node_spawn_x(self)
