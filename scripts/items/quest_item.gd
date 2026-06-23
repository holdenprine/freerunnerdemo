extends Area2D
## Quest item picked up when the player walks into it.

@export var item_id := "quest_item"
@export var display_name := "Quest Item"
@export var item_color := Color(0.95, 0.8, 0.15, 1)

@onready var visual: ColorRect = $Visual


func _ready() -> void:
	add_to_group("quest_items")
	add_to_group("spawn_avoid")
	visual.color = item_color
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameState.quest_completed or GameState.is_quest_item_collected(item_id):
		return

	GameState.pick_up_quest_item(item_id)
	queue_free()
