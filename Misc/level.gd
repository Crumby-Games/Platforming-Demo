extends Node2D
class_name Level

signal level_complete(score: int)

@export var flags_required: int = 1

var flags_collected = 0
var optionals_collected = 0


func collect_optional() -> void:
	optionals_collected += 1

func collect_flag() -> void:
	flags_collected += 1
	if flags_collected >= flags_required:
		level_complete.emit(optionals_collected)
		World.load_menu()
