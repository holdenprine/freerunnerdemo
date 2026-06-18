extends Area2D
class_name ScrollHazard
## Base hazard that scrolls left and despawns off-screen.

@export var despawn_margin := 80.0

var _scroll_speed := GameState.BASE_SCROLL_SPEED


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	EventBus.scroll_speed_changed.connect(_on_scroll_speed_changed)
	_scroll_speed = GameState.scroll_speed


func _physics_process(delta: float) -> void:
	if not GameState.is_playing:
		return
	position.x -= _scroll_speed * delta
	if position.x < -despawn_margin:
		queue_free()


func _on_scroll_speed_changed(new_speed: float) -> void:
	_scroll_speed = new_speed


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.end_run()
