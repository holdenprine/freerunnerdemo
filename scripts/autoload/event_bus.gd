extends Node
## Global signal bus for decoupled game events.
## Signals are emitted/connected from other scripts via the EventBus autoload.

@warning_ignore_start("unused_signal")
signal game_started
signal game_over
signal game_reset
signal game_won
signal hits_changed(remaining_hits: int)
signal invulnerability_started
signal invulnerability_ended
signal quest_item_picked_up
signal quest_progress_changed
signal quest_items_placed
signal scroll_speed_changed(new_speed: float)
signal dialog_requested(title: String, message: String)
signal dialog_closed
signal win_screen_requested
