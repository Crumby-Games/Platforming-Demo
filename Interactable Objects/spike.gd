extends Interactable

func _on_player_touched(player: Player) -> void:
	player.die()