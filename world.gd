extends Node

var loading: bool = false

func load_level(level_scene: PackedScene) -> void:
	if loading:
		await get_tree().scene_changed
	loading = true
	get_tree().change_scene_to_packed(level_scene)
	await get_tree().scene_changed
	loading = false

func get_level() -> Level:
	assert(get_tree().current_scene is Level)
	return get_tree().current_scene

func restart_level():
	if loading:
		await get_tree().scene_changed
	assert(get_tree().current_scene is Level)
	loading = true
	get_tree().call_deferred("reload_current_scene")
	await get_tree().scene_changed
	loading = false

func load_menu() -> void:
	if loading:
		await get_tree().scene_changed
	assert(get_tree().current_scene is Level)
	get_tree().change_scene_to_file("res://Top-Level Scenes/Main Menu.tscn")
