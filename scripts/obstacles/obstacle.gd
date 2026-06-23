extends MovingHazard
## Ground obstacle — player must jump over it.


func on_player_hit(_body: Node2D) -> void:
	GameState.take_hit()
