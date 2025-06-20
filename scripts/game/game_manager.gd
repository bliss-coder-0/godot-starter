extends Node

var game_data: GameData = GameData.new()

var save_file_path = "user://save"
var save_file_name = "game_data.json"

signal loaded
signal paused
signal unpaused

func _ready():
	call_deferred("_load")
	
func _load():
	GameUtils.verify_save_dir(save_file_path)
	var data = GameUtils.restore(save_file_path.path_join(save_file_name))
	if data == null:
		data = save()
	restore(data)
	if not game_data.first_time_loaded:
		game_data.set_default()
		save()
	loaded.emit()
	
func save():
	return GameUtils.save(save_file_path.path_join(save_file_name), game_data.save())
	
func restore(data):
	game_data.restore(data)

func reset():
	game_data.reset()

func is_paused() -> bool:
	return get_tree().paused

func pause():
	get_tree().paused = true
	paused.emit()

func unpause():
	get_tree().paused = false
	unpaused.emit()

func quit():
	get_tree().quit()

func restart():
	game_data.reset()
	get_tree().reload_current_scene()
