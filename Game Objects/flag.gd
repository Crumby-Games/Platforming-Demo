extends Interactable

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _on_player_touched(_player: Player) -> void:
	animated_sprite.play("flag_out")
	await animated_sprite.animation_finished
	animated_sprite.play("flag_idle")
	await get_tree().create_timer(1).timeout
	World.get_level().collect_flag()
