extends Node
## Places all quest items with mutual separation inside the safe spawn band.

@export var ground_y := 360.0
@export var min_quest_item_separation := 250.0


func _ready() -> void:
	call_deferred("_place_all_quest_items")


func _place_all_quest_items() -> void:
	var bounds := get_parent() as WorldBounds
	if bounds == null:
		return

	var items: Array[Node2D] = []
	for node in get_tree().get_nodes_in_group("quest_items"):
		if node is Node2D:
			items.append(node)

	items.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return a.name < b.name
	)

	var placed_x: Array[float] = []
	var avoid := bounds.get_avoid_x_positions()

	for item in items:
		var combined_avoid := avoid + placed_x
		var x := bounds.random_safe_spawn_x(combined_avoid, min_quest_item_separation)
		item.global_position = Vector2(x, ground_y)
		placed_x.append(x)

	EventBus.quest_items_placed.emit()
