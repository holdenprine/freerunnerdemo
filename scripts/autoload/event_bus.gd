extends Node
## Global signal bus for decoupled game events.

signal game_started
signal game_over
signal game_reset
signal score_changed(new_score: int)
signal scroll_speed_changed(new_speed: float)
signal dialog_requested(title: String, message: String)
signal dialog_closed
