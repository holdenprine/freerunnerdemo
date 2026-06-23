extends Node2D
## Drives difficulty scaling and run lifecycle for the active game scene.


func _ready() -> void:
	EventBus.game_over.connect(_on_game_over)
	EventBus.game_reset.connect(_on_game_reset)
	EventBus.quest_items_placed.connect(_begin_run, CONNECT_ONE_SHOT)


func _process(delta: float) -> void:
	GameState.tick(delta)


func _begin_run() -> void:
	GameState.start_run()


func _on_game_over() -> void:
	pass


func _on_game_reset() -> void:
	get_tree().reload_current_scene()
