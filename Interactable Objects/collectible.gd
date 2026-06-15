extends Interactable

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _on_player_touched(_player: Player) -> void:
	animated_sprite.play("collect")
	await animated_sprite.animation_finished
	World.get_level().collect_optional()
	queue_free()
