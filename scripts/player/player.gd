extends CharacterBody2D
## Platform runner with horizontal movement, jump, duck, and world wrap.

const GRAVITY := 1800.0
const JUMP_VELOCITY := -620.0
const RUN_SPEED := 280.0
const DUCK_HEIGHT := 30.0
const STAND_HEIGHT := 60.0
const STAND_WIDTH := 40.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: ColorRect = $Visual
@onready var stand_shape: RectangleShape2D = collision_shape.shape

var _is_ducking := false
var _duck_shape := RectangleShape2D.new()
var _world_bounds: WorldBounds
var _flicker_tween: Tween


func _ready() -> void:
	_duck_shape.size = Vector2(STAND_WIDTH, DUCK_HEIGHT)
	_apply_stance(false)
	_world_bounds = get_parent() as WorldBounds
	EventBus.invulnerability_started.connect(_on_invulnerability_started)
	EventBus.invulnerability_ended.connect(_on_invulnerability_ended)
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_over.connect(_on_game_over)


func _physics_process(delta: float) -> void:
	if not GameState.is_playing or GameState.is_dialog_open:
		velocity = Vector2.ZERO
		return

	_apply_world_wrap()
	_handle_input()

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()
	_apply_world_wrap()


func _apply_world_wrap() -> void:
	if _world_bounds == null:
		return
	if not _world_bounds.should_wrap_x(global_position.x):
		return

	global_position = _world_bounds.wrap_position(global_position)
	# Re-test floor contact so the player does not keep falling after a wrap.
	move_and_slide()


func _handle_input() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * RUN_SPEED

	var wants_duck := (
		Input.is_action_pressed("duck")
		or Input.is_action_pressed("move_down")
	)

	if wants_duck and is_on_floor():
		_apply_stance(true)
	elif not wants_duck:
		_apply_stance(false)

	if Input.is_action_just_pressed("jump") and is_on_floor() and not _is_ducking:
		velocity.y = JUMP_VELOCITY


func _apply_stance(ducking: bool) -> void:
	if _is_ducking == ducking:
		return
	_is_ducking = ducking

	if ducking:
		collision_shape.shape = _duck_shape
		collision_shape.position = Vector2(0.0, -DUCK_HEIGHT * 0.5)
		visual.size = Vector2(STAND_WIDTH, DUCK_HEIGHT)
		visual.position = Vector2(-STAND_WIDTH * 0.5, -DUCK_HEIGHT)
	else:
		collision_shape.shape = stand_shape
		collision_shape.position = Vector2(0.0, -STAND_HEIGHT * 0.5)
		visual.size = Vector2(STAND_WIDTH, STAND_HEIGHT)
		visual.position = Vector2(-STAND_WIDTH * 0.5, -STAND_HEIGHT)


func _on_invulnerability_started() -> void:
	_start_flicker()


func _on_invulnerability_ended() -> void:
	_stop_flicker()


func _on_game_started() -> void:
	_stop_flicker()


func _on_game_over() -> void:
	_stop_flicker()


func _start_flicker() -> void:
	_stop_flicker()
	_flicker_tween = create_tween().set_loops()
	_flicker_tween.tween_property(visual, "modulate:a", 0.15, 0.08)
	_flicker_tween.tween_property(visual, "modulate:a", 1.0, 0.08)


func _stop_flicker() -> void:
	if _flicker_tween:
		_flicker_tween.kill()
		_flicker_tween = null
	visual.modulate = Color.WHITE
