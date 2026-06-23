extends MovingHazard
## Flying enemy — colliding with the player costs one hit point.

@export var fly_height := 70.0


func on_player_hit(_body: Node2D) -> void:
	GameState.take_hit()
