extends CharacterBody2D
## Side-scrolling runner: jump over ground hazards, duck under flying ones.

const GRAVITY := 1800.0
const JUMP_VELOCITY := -620.0
const DUCK_HEIGHT := 30.0
const STAND_HEIGHT := 60.0
const STAND_WIDTH := 40.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: ColorRect = $Visual
@onready var stand_shape: RectangleShape2D = collision_shape.shape

var _is_ducking := false
var _duck_shape := RectangleShape2D.new()


func _ready() -> void:
	_duck_shape.size = Vector2(STAND_WIDTH, DUCK_HEIGHT)
	_apply_stance(false)


func _physics_process(delta: float) -> void:
	if not GameState.is_playing:
		return

	_handle_input()

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

	velocity.x = 0.0
	move_and_slide()


func _handle_input() -> void:
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
