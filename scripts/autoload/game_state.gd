extends Node
## Tracks run state, hit points, difficulty scaling, and quest progress.

const BASE_SCROLL_SPEED := 300.0
const MAX_SCROLL_SPEED := 700.0
const SPEED_RAMP_PER_SECOND := 8.0
const MAX_HITS := 3
const INVULNERABILITY_DURATION := 1.5

var is_playing := false
var is_game_over := false
var is_dialog_open := false
var is_invulnerable := false
var quest_completed := false
var quest_items_required := 1
var quest_items_collected := 0
var quest_objective_entries: Array[Dictionary] = []
var hits_remaining := MAX_HITS
var scroll_speed := BASE_SCROLL_SPEED
var elapsed_time := 0.0


func start_run() -> void:
	is_playing = true
	is_game_over = false
	is_dialog_open = false
	is_invulnerable = false
	quest_completed = false
	quest_items_collected = 0
	_refresh_quest_objectives()
	hits_remaining = MAX_HITS
	elapsed_time = 0.0
	scroll_speed = BASE_SCROLL_SPEED
	EventBus.game_started.emit()
	EventBus.hits_changed.emit(hits_remaining)
	EventBus.quest_progress_changed.emit()
	EventBus.scroll_speed_changed.emit(scroll_speed)


func _refresh_quest_objectives() -> void:
	quest_objective_entries.clear()
	for item in get_tree().get_nodes_in_group("quest_items"):
		var entry_id: String = str(item.get("item_id")) if item.get("item_id") != null else str(item.name)
		var entry_name: String = str(item.get("display_name")) if item.get("display_name") != null else "Quest Item"
		quest_objective_entries.append({
			"id": entry_id,
			"display_name": entry_name,
			"collected": false,
		})

	if quest_objective_entries.is_empty():
		quest_objective_entries.append({
			"id": "quest_item",
			"display_name": "Quest Item",
			"collected": false,
		})

	quest_items_required = quest_objective_entries.size()


func is_quest_item_collected(item_id: String) -> bool:
	for entry in quest_objective_entries:
		if entry.id == item_id:
			return entry.collected
	return false


func get_quest_items_remaining() -> int:
	var count := 0
	for entry in quest_objective_entries:
		if not entry.collected:
			count += 1
	return count


func get_quest_tracker_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry in quest_objective_entries:
		entries.append(entry.duplicate())
	return entries


func has_all_quest_items() -> bool:
	return quest_items_collected >= quest_items_required


func take_hit() -> void:
	if is_game_over or is_invulnerable:
		return

	hits_remaining = maxi(hits_remaining - 1, 0)
	EventBus.hits_changed.emit(hits_remaining)
	_start_invulnerability()
	if hits_remaining <= 0:
		end_run()


func _start_invulnerability() -> void:
	is_invulnerable = true
	EventBus.invulnerability_started.emit()
	get_tree().create_timer(INVULNERABILITY_DURATION).timeout.connect(_end_invulnerability)


func _end_invulnerability() -> void:
	if not is_invulnerable:
		return
	is_invulnerable = false
	EventBus.invulnerability_ended.emit()


func pick_up_quest_item(item_id: String) -> void:
	if quest_completed or is_quest_item_collected(item_id):
		return

	for entry in quest_objective_entries:
		if entry.id != item_id or entry.collected:
			continue
		entry.collected = true
		quest_items_collected += 1
		EventBus.quest_item_picked_up.emit()
		EventBus.quest_progress_changed.emit()
		return


func complete_quest() -> void:
	if quest_completed:
		return
	quest_completed = true
	is_playing = false
	EventBus.game_won.emit()
	EventBus.win_screen_requested.emit()
	EventBus.quest_progress_changed.emit()


func end_run() -> void:
	if is_game_over:
		return
	is_playing = false
	is_game_over = true
	EventBus.game_over.emit()


func reset_run() -> void:
	is_playing = false
	is_game_over = false
	is_dialog_open = false
	is_invulnerable = false
	quest_completed = false
	quest_items_collected = 0
	hits_remaining = MAX_HITS
	elapsed_time = 0.0
	scroll_speed = BASE_SCROLL_SPEED
	EventBus.game_reset.emit()
	EventBus.hits_changed.emit(hits_remaining)
	EventBus.quest_progress_changed.emit()
	EventBus.scroll_speed_changed.emit(scroll_speed)


func tick(delta: float) -> void:
	if not is_playing:
		return
	elapsed_time += delta
	scroll_speed = min(
		BASE_SCROLL_SPEED + elapsed_time * SPEED_RAMP_PER_SECOND,
		MAX_SCROLL_SPEED
	)
	EventBus.scroll_speed_changed.emit(scroll_speed)
