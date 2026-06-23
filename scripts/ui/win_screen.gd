extends Control
## Victory popup shown after the player returns the quest item.

@onready var continue_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ContinueButton


func _ready() -> void:
	hide()
	continue_button.pressed.connect(_on_continue_pressed)
	EventBus.win_screen_requested.connect(_show)


func _show() -> void:
	show()


func _on_continue_pressed() -> void:
	hide()
	GameState.reset_run()
