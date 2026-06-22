extends CanvasLayer
## Simple modal dialog opened via EventBus.dialog_requested.

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var message_label: Label = $Panel/MarginContainer/VBoxContainer/MessageLabel
@onready var close_hint: Label = $Panel/MarginContainer/VBoxContainer/CloseHint


func _ready() -> void:
	EventBus.dialog_requested.connect(_open_dialog)
	panel.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not GameState.is_dialog_open:
		return

	if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_dialog()


func _open_dialog(title: String, message: String) -> void:
	GameState.is_dialog_open = true
	title_label.text = title
	message_label.text = message
	panel.show()


func _close_dialog() -> void:
	GameState.is_dialog_open = false
	panel.hide()
	EventBus.dialog_closed.emit()
