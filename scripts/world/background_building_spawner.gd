extends Node2D
## Spawns skyline building sprites near the top edge, scrolling at parallax speed.

const BUILDING_TEXTURES: Array[Texture2D] = [
	preload("res://art/Building Set 1.png"),
	preload("res://art/Building Set 2.png"),
	preload("res://art/Building Set 3.png"),
]

@export var top_margin := 12.0
@export var building_scale := 3.0
@export var parallax_factor := 0.35
@export var spawn_x := 1040.0
@export var min_spawn_interval := 3.5
@export var max_spawn_interval := 7.0
@export var initial_building_count := 4
@export var min_building_spacing := 120.0
@export var max_building_spacing := 220.0
@export var initial_start_x := 640.0
@export var despawn_margin := 480.0

var _timer := 0.0
var _scroll_speed := GameState.BASE_SCROLL_SPEED


func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_reset.connect(_on_game_reset)
	EventBus.scroll_speed_changed.connect(_on_scroll_speed_changed)
	_scroll_speed = GameState.scroll_speed


func _process(delta: float) -> void:
	if not GameState.is_playing:
		return

	_scroll_buildings(delta)

	_timer -= delta
	if _timer <= 0.0:
		_spawn_building()
		_reset_timer()

	_despawn_offscreen()


func _scroll_buildings(delta: float) -> void:
	var scroll_amount := _scroll_speed * parallax_factor * delta
	for child in get_children():
		if child is Sprite2D:
			child.position.x -= scroll_amount


func _populate_initial() -> void:
	var cursor_x := initial_start_x
	for i in initial_building_count:
		var building := _create_building_sprite()
		building.position.x = cursor_x
		add_child(building)
		cursor_x += randf_range(min_building_spacing, max_building_spacing) * building_scale


func _spawn_building() -> void:
	var building := _create_building_sprite()
	building.position = Vector2(spawn_x, top_margin)
	add_child(building)


func _create_building_sprite() -> Sprite2D:
	var building := Sprite2D.new()
	building.texture = BUILDING_TEXTURES.pick_random()
	building.centered = false
	building.scale = Vector2.ONE * building_scale
	building.position.y = top_margin
	return building


func _despawn_offscreen() -> void:
	for child in get_children():
		if child is Sprite2D and child.position.x < -despawn_margin:
			child.queue_free()


func _reset_timer() -> void:
	_timer = randf_range(min_spawn_interval, max_spawn_interval)


func _clear_buildings() -> void:
	for child in get_children():
		child.queue_free()


func _on_game_started() -> void:
	_clear_buildings()
	_populate_initial()
	_reset_timer()


func _on_game_reset() -> void:
	_clear_buildings()
	_timer = 0.0


func _on_scroll_speed_changed(new_speed: float) -> void:
	_scroll_speed = new_speed
