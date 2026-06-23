extends Control
## Game over overlay with Retry, Back to Menu, and Quit.

@onready var retry_button: Button = $CenterContainer/VBoxContainer/RetryButton
@onready var back_to_menu_button: Button = $CenterContainer/VBoxContainer/BackToMenuButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	hide()
	retry_button.pressed.connect(_on_retry_pressed)
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	EventBus.game_over.connect(_on_game_over)
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_reset.connect(_on_game_reset)


func _on_game_over() -> void:
	show()


func _on_game_started() -> void:
	hide()


func _on_game_reset() -> void:
	hide()


func _on_retry_pressed() -> void:
	GameState.reset_run()


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start/start_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
