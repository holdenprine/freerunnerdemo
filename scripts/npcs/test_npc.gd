extends Node2D
## Quest NPC with dialog that changes based on quest progress.

@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_label: Label = $PromptLabel

@export var npc_name := "Villager"
@export_multiline var dialog_need_one_item := "Please, traveler — I lost a quest item somewhere out there.\n\nFind it and bring it back to me.\n\nPress Esc to close."
@export_multiline var dialog_need_many_items := "Please, traveler — I lost %d quest items out there.\n\nFind them all and bring them back to me.\n\nPress Esc to close."
@export_multiline var dialog_need_more_items := "Thank you, but I still need %d more quest item(s).\n\nPress Esc to close."
@export_multiline var dialog_with_all_items := "Thank you! You found everything!\n\nPress Esc to close."

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

	if GameState.has_all_quest_items():
		_pending_win_after_dialog = true
		EventBus.dialog_requested.emit(npc_name, dialog_with_all_items)
		return

	var remaining := GameState.get_quest_items_remaining()
	if GameState.quest_items_collected > 0:
		EventBus.dialog_requested.emit(npc_name, dialog_need_more_items % remaining)
		return

	if remaining > 1:
		EventBus.dialog_requested.emit(npc_name, dialog_need_many_items % remaining)
	else:
		EventBus.dialog_requested.emit(npc_name, dialog_need_one_item)


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
