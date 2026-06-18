extends ParallaxBackground
## Scrolls parallax layers based on current run speed.

@export var speed_multiplier := 1.0

var _scroll_speed := GameState.BASE_SCROLL_SPEED


func _ready() -> void:
	EventBus.scroll_speed_changed.connect(_on_scroll_speed_changed)
	_scroll_speed = GameState.scroll_speed


func _process(delta: float) -> void:
	if not GameState.is_playing:
		return
	scroll_offset.x += _scroll_speed * speed_multiplier * delta


func _on_scroll_speed_changed(new_speed: float) -> void:
	_scroll_speed = new_speed
