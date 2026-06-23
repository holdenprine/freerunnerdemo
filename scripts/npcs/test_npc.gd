extends Node2D
## Quest NPC with dialog that changes based on whether the player has the quest item.

@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_label: Label = $PromptLabel

@export var npc_name := "Villager"
@export_multiline var dialog_without_item := "Please, traveler — I lost my quest item somewhere out there.\n\nFind it and bring it back to me.\n\nPress Esc to close."
@export_multiline var dialog_with_item := "Thank you! You found my quest item!\n\nPress Esc to close."

var _player_nearby := false
var _pending_win_after_dialog := false


func _ready() -> void:
	if not is_in_group("spawn_avoid"):
		add_to_group("spawn_avoid")

	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	EventBus.dialog_closed.connect(_on_dialog_closed)
	prompt_label.hide()

	var bounds: WorldBounds = get_parent() as WorldBounds
	if bounds == null:
		bounds = get_tree().get_first_node_in_group("world_bounds") as WorldBounds
	if bounds:
		bounds.clamp_node_spawn_x(self)


func _process(_delta: float) -> void:
	var can_interact: bool = _player_nearby and not GameState.is_dialog_open and not GameState.quest_completed
	prompt_label.visible = can_interact

	if can_interact and Input.is_action_just_pressed("interact"):
		_open_dialog()


func _open_dialog() -> void:
	if GameState.quest_completed:
		return

	if GameState.has_quest_item:
		_pending_win_after_dialog = true
		EventBus.dialog_requested.emit(npc_name, dialog_with_item)
	else:
		EventBus.dialog_requested.emit(npc_name, dialog_without_item)


func _on_dialog_closed() -> void:
	if not _pending_win_after_dialog:
		return
	_pending_win_after_dialog = false
	GameState.complete_quest()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
