extends Button

@export var level: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(level) # REQUIRES LEVEL SCENE TO BE ADDED IN THE EDITOR

func _on_pressed() -> void:
	World.load_level(level)
