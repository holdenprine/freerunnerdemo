extends CanvasLayer
## Displays live score and game-over prompts.

@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var high_score_label: Label = $MarginContainer/VBoxContainer/HighScoreLabel
@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var game_over_label: Label = $GameOverPanel/MarginContainer/VBoxContainer/GameOverLabel
@onready var restart_hint: Label = $GameOverPanel/MarginContainer/VBoxContainer/RestartHint


func _ready() -> void:
	EventBus.score_changed.connect(_on_score_changed)
	EventBus.game_over.connect(_on_game_over)
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_reset.connect(_on_game_reset)
	game_over_panel.hide()
	_on_score_changed(GameState.score)
	high_score_label.text = "HI %06d" % GameState.high_score


func _unhandled_input(event: InputEvent) -> void:
	if not GameState.is_game_over:
		return
	if event.is_action_pressed("restart") or event.is_action_pressed("jump"):
		get_viewport().set_input_as_handled()
		GameState.reset_run()


func _on_score_changed(new_score: int) -> void:
	score_label.text = "%06d" % new_score


func _on_game_started() -> void:
	game_over_panel.hide()
	high_score_label.text = "HI %06d" % GameState.high_score


func _on_game_over() -> void:
	game_over_panel.show()
	game_over_label.text = "GAME OVER"
	restart_hint.text = "Press Jump or R to restart"
	if GameState.score >= GameState.high_score:
		high_score_label.text = "HI %06d" % GameState.high_score


func _on_game_reset() -> void:
	game_over_panel.hide()
