extends CanvasLayer
## Displays hit counter during gameplay.

@onready var hit_counter: HBoxContainer = $MarginContainer/HitCounter

var _hit_circles: Array[HitCircle] = []


func _ready() -> void:
	EventBus.hits_changed.connect(_on_hits_changed)
	EventBus.game_started.connect(_on_game_started)
	_build_hit_counter()
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


func _on_hits_changed(remaining_hits: int) -> void:
	for i in _hit_circles.size():
		_hit_circles[i].is_filled = i < remaining_hits


func _on_game_started() -> void:
	_on_hits_changed(GameState.hits_remaining)
