extends Camera2D
## Follows the player on X only so jumps do not shift the background.

@export var follow_y := 270.0

var _player: Node2D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if _player == null:
		return
	global_position.x = _player.global_position.x
	global_position.y = follow_y
