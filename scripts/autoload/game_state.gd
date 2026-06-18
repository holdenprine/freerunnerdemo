extends Node
## Tracks run state, score, and difficulty scaling.

const BASE_SCROLL_SPEED := 300.0
const MAX_SCROLL_SPEED := 700.0
const SPEED_RAMP_PER_SECOND := 8.0

var is_playing := false
var is_game_over := false
var score := 0
var high_score := 0
var scroll_speed := BASE_SCROLL_SPEED
var elapsed_time := 0.0


func start_run() -> void:
	is_playing = true
	is_game_over = false
	score = 0
	elapsed_time = 0.0
	scroll_speed = BASE_SCROLL_SPEED
	EventBus.game_started.emit()
	EventBus.score_changed.emit(score)
	EventBus.scroll_speed_changed.emit(scroll_speed)


func end_run() -> void:
	if is_game_over:
		return
	is_playing = false
	is_game_over = true
	if score > high_score:
		high_score = score
	EventBus.game_over.emit()


func reset_run() -> void:
	is_playing = false
	is_game_over = false
	score = 0
	elapsed_time = 0.0
	scroll_speed = BASE_SCROLL_SPEED
	EventBus.game_reset.emit()
	EventBus.score_changed.emit(score)
	EventBus.scroll_speed_changed.emit(scroll_speed)


func tick(delta: float) -> void:
	if not is_playing:
		return
	elapsed_time += delta
	score = int(elapsed_time * 10.0)
	scroll_speed = min(
		BASE_SCROLL_SPEED + elapsed_time * SPEED_RAMP_PER_SECOND,
		MAX_SCROLL_SPEED
	)
	EventBus.score_changed.emit(score)
	EventBus.scroll_speed_changed.emit(scroll_speed)
