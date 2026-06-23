extends CanvasLayer
## Displays hit counter and game-over prompts.

@onready var hit_counter: HBoxContainer = $MarginContainer/HitCounter
@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var game_over_label: Label = $GameOverPanel/MarginContainer/VBoxContainer/GameOverLabel
@onready var restart_hint: Label = $GameOverPanel/MarginContainer/VBoxContainer/RestartHint

var _hit_circles: Array[HitCircle] = []


func _ready() -> void:
	EventBus.hits_changed.connect(_on_hits_changed)
	EventBus.game_over.connect(_on_game_over)
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_reset.connect(_on_game_reset)
	_build_hit_counter()
	game_over_panel.hide()
	_on_hits_changed(GameState.hits_remaining)


func _build_hit_counter() -> void:
	for child in hit_counter.get_children():
		child.queue_free()
	_hit_circles.clear()

	for i in GameState.MAX_HITS:
		var circle := HitCircle.new()
		circle.name = "HitCircle%d" % i
		hit_counter.add_child(circle)
		_hit_circles.append(circle)


func _unhandled_input(event: InputEvent) -> void:
	if not GameState.is_game_over:
		return
	if event.is_action_pressed("restart") or event.is_action_pressed("jump"):
		get_viewport().set_input_as_handled()
		GameState.reset_run()


func _on_hits_changed(remaining_hits: int) -> void:
	for i in _hit_circles.size():
		_hit_circles[i].is_filled = i < remaining_hits


func _on_game_started() -> void:
	game_over_panel.hide()
	_on_hits_changed(GameState.hits_remaining)


func _on_game_over() -> void:
	game_over_panel.show()
	game_over_label.text = "GAME OVER"
	restart_hint.text = "Press Jump or R to restart"


func _on_game_reset() -> void:
	game_over_panel.hide()
