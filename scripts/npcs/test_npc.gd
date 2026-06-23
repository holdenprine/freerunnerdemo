extends Node2D
## Test NPC that opens a dialog when the player presses interact nearby.

@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_label: Label = $PromptLabel

@export var dialog_title := "Test NPC"
@export_multiline var dialog_message := "Hello! This is a test dialog box.\n\nPress Esc to close."

var _player_nearby := false


func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	prompt_label.hide()


func _process(_delta: float) -> void:
	prompt_label.visible = _player_nearby and not GameState.is_dialog_open

	if _player_nearby and Input.is_action_just_pressed("interact") and not GameState.is_dialog_open:
		EventBus.dialog_requested.emit(dialog_title, dialog_message)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
