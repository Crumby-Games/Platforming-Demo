extends Area2D
class_name Interactable

var can_interact = true

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is Player && can_interact:
		can_interact = false
		_on_player_touched(body)

func _on_player_touched(_player: Player) -> void:
	pass
