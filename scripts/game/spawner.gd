extends Node2D
## Spawns obstacles and flying enemies ahead of the player.

@export var spawn_x := 900.0
@export var ground_y := 360.0
@export var min_spawn_interval := 1.4
@export var max_spawn_interval := 2.8
@export var enemy_fly_height := 70.0

@onready var obstacle_scene: PackedScene = preload("res://scenes/obstacles/obstacle_cactus.tscn")
@onready var enemy_scene: PackedScene = preload("res://scenes/enemies/enemy_bird.tscn")

var _timer := 0.0
var _next_spawn_in := 2.0


func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_reset.connect(_on_game_reset)
	EventBus.game_over.connect(_on_game_over)
	_reset_timer()


func _process(delta: float) -> void:
	if not GameState.is_playing:
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


func _spawn_obstacle() -> void:
	var obstacle := obstacle_scene.instantiate() as Node2D
	obstacle.position = Vector2(spawn_x, ground_y)
	add_child(obstacle)


func _spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate() as Node2D
	enemy.position = Vector2(spawn_x, ground_y - enemy_fly_height)
	add_child(enemy)


func _reset_timer() -> void:
	var difficulty := clampf(GameState.elapsed_time / 90.0, 0.0, 1.0)
	var min_interval := lerpf(max_spawn_interval, min_spawn_interval, difficulty)
	var max_interval := lerpf(max_spawn_interval + 0.6, min_spawn_interval + 0.4, difficulty)
	_next_spawn_in = randf_range(min_interval, max_interval)
	_timer = _next_spawn_in


func _clear_spawned_hazards() -> void:
	for child in get_children():
		if child is ScrollHazard:
			child.queue_free()


func _on_game_started() -> void:
	_clear_spawned_hazards()
	_reset_timer()


func _on_game_reset() -> void:
	_clear_spawned_hazards()
	_timer = 0.0


func _on_game_over() -> void:
	_timer = 0.0
