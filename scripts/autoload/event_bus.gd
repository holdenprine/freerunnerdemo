extends Node
## Global signal bus for decoupled game events.

signal game_started
signal game_over
signal game_reset
signal hits_changed(remaining_hits: int)
signal invulnerability_started
signal invulnerability_ended
signal scroll_speed_changed(new_speed: float)
signal dialog_requested(title: String, message: String)
signal dialog_closed
