extends Node2D
## Spawns hazards from either side of the player's current view.

@export var ground_y := 360.0
@export var min_spawn_interval := 1.4
@export var max_spawn_interval := 2.8
@export var enemy_fly_height := 70.0
@export var offscreen_margin := 80.0

@onready var obstacle_scene: PackedScene = preload("res://scenes/obstacles/obstacle_cactus.tscn")
@onready var enemy_scene: PackedScene = preload("res://scenes/enemies/enemy_bird.tscn")
@onready var _player: Node2D = $"../Player"

var _timer := 0.0
var _viewport_width := 960.0


func _ready() -> void:
	_viewport_width = get_viewport().get_visible_rect().size.x
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_reset.connect(_on_game_reset)
	EventBus.game_over.connect(_on_game_over)
	_reset_timer()


func _process(delta: float) -> void:
	if not GameState.is_playing or GameState.is_dialog_open:
		return

	_timer -= delta
	if _timer <= 0.0:
		_spawn_hazard()
		_reset_timer()


func _spawn_hazard() -> void:
	var roll := randf()
	var difficulty := clampf(GameState.elapsed_time / 60.0, 0.0, 1.0)
	var enemy_chance := lerpf(0.15, 0.45, difficulty)

	if roll < enemy_chance:
		_spawn_enemy()
	else:
		_spawn_obstacle()


func _spawn_from_random_side() -> Dictionary:
	var center_x := _player.global_position.x
	var half_width := _viewport_width * 0.5
	var from_left := randf() > 0.5
	var spawn_x := center_x - half_width - offscreen_margin if from_left else center_x + half_width + offscreen_margin
	var direction := 1.0 if from_left else -1.0
	return {"spawn_x": spawn_x, "direction": direction}


func _spawn_obstacle() -> void:
	var spawn := _spawn_from_random_side()
	var obstacle := obstacle_scene.instantiate() as MovingHazard
	obstacle.position = Vector2(spawn.spawn_x, ground_y)
	add_child(obstacle)
	obstacle.setup(spawn.direction)


func _spawn_enemy() -> void:
	var spawn := _spawn_from_random_side()
	var enemy := enemy_scene.instantiate() as MovingHazard
	enemy.position = Vector2(spawn.spawn_x, ground_y - enemy_fly_height)
	add_child(enemy)
	enemy.setup(spawn.direction)


func _reset_timer() -> void:
	var difficulty := clampf(GameState.elapsed_time / 90.0, 0.0, 1.0)
	var min_interval := lerpf(max_spawn_interval, min_spawn_interval, difficulty)
	var max_interval := lerpf(max_spawn_interval + 0.6, min_spawn_interval + 0.4, difficulty)
	_timer = randf_range(min_interval, max_interval)


func _clear_spawned_hazards() -> void:
	for child in get_children():
		if child is MovingHazard:
			child.queue_free()


func _on_game_started() -> void:
	_clear_spawned_hazards()
	_reset_timer()


func _on_game_reset() -> void:
	_clear_spawned_hazards()
	_timer = 0.0


func _on_game_over() -> void:
	_timer = 0.0
