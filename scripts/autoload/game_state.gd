extends Node
## Tracks run state, hit points, and difficulty scaling.

const BASE_SCROLL_SPEED := 300.0
const MAX_SCROLL_SPEED := 700.0
const SPEED_RAMP_PER_SECOND := 8.0
const MAX_HITS := 3
const INVULNERABILITY_DURATION := 2.0

var is_playing := false
var is_game_over := false
var is_dialog_open := false
var is_invulnerable := false
var hits_remaining := MAX_HITS
var scroll_speed := BASE_SCROLL_SPEED
var elapsed_time := 0.0


func start_run() -> void:
	is_playing = true
	is_game_over = false
	is_dialog_open = false
	is_invulnerable = false
	hits_remaining = MAX_HITS
	elapsed_time = 0.0
	scroll_speed = BASE_SCROLL_SPEED
	EventBus.game_started.emit()
	EventBus.hits_changed.emit(hits_remaining)
	EventBus.scroll_speed_changed.emit(scroll_speed)


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
	hits_remaining = MAX_HITS
	elapsed_time = 0.0
	scroll_speed = BASE_SCROLL_SPEED
	EventBus.game_reset.emit()
	EventBus.hits_changed.emit(hits_remaining)
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
