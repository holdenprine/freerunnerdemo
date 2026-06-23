extends CanvasLayer
## Displays hit counter and quest objectives with strikethrough progress.

const STRIKE_LINE_HEIGHT := 2.0

@onready var hit_counter: HBoxContainer = $MarginContainer/VBoxContainer/HitCounter
@onready var quest_tracker: VBoxContainer = $MarginContainer/VBoxContainer/QuestTracker
var _hit_circles: Array[HitCircle] = []


func _ready() -> void:
	EventBus.hits_changed.connect(_on_hits_changed)
	EventBus.quest_progress_changed.connect(_on_quest_progress_changed)
	EventBus.game_started.connect(_on_game_started)
	_build_hit_counter()
	_on_hits_changed(GameState.hits_remaining)
	_rebuild_quest_tracker()


func _build_hit_counter() -> void:
	for child in hit_counter.get_children():
		child.queue_free()
	_hit_circles.clear()

	for i in GameState.MAX_HITS:
		var circle := HitCircle.new()
		circle.name = "HitCircle%d" % i
		hit_counter.add_child(circle)
		_hit_circles.append(circle)


func _rebuild_quest_tracker() -> void:
	for child in quest_tracker.get_children():
		child.queue_free()

	var entries: Array[Dictionary] = GameState.get_quest_tracker_entries()
	quest_tracker.visible = not GameState.quest_completed and not entries.is_empty()

	for entry in entries:
		var row := _create_quest_entry_row(entry.display_name, entry.collected)
		quest_tracker.add_child(row)


func _create_quest_entry_row(display_name: String, collected: bool) -> Control:
	var row := Control.new()
	var label := Label.new()
	label.text = "• %s" % display_name
	label.add_theme_font_size_override("font_size", 16)
	row.add_child(label)

	label.resized.connect(_update_row_size.bind(label))
	call_deferred("_update_row_size", label)

	if collected:
		var strike := ColorRect.new()
		strike.color = Color.BLACK
		strike.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(strike)
		label.resized.connect(_update_strike_line.bind(label, strike))
		call_deferred("_update_strike_line", label, strike)

	return row


func _update_row_size(label: Label) -> void:
	var row := label.get_parent() as Control
	if row:
		row.custom_minimum_size = label.get_combined_minimum_size()


func _update_strike_line(label: Label, strike: ColorRect) -> void:
	var text_width := label.get_combined_minimum_size().x
	var text_height := label.get_combined_minimum_size().y
	strike.position = Vector2(0.0, text_height * 0.5 - STRIKE_LINE_HEIGHT * 0.5)
	strike.size = Vector2(text_width, STRIKE_LINE_HEIGHT)

	var row := label.get_parent() as Control
	if row:
		row.custom_minimum_size = Vector2(text_width, text_height)

func _on_hits_changed(remaining_hits: int) -> void:
	for i in _hit_circles.size():
		_hit_circles[i].is_filled = i < remaining_hits


func _on_quest_progress_changed() -> void:
	_rebuild_quest_tracker()


func _on_game_started() -> void:
	_on_hits_changed(GameState.hits_remaining)
	_rebuild_quest_tracker()
