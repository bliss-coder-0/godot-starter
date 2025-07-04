extends Node

enum SaveGameMode {NONE, SAVE, RESTORE}

var save_game_mode = SaveGameMode.NONE
var save_games = []
var loaded_restore_index = 0

func _ready():
	pass
	#SceneManager.loaded.connect(_on_loaded)
	#_remove_all_files()
	#reset()

func restart():
	reset()
	#await SceneManager.goto_scene(play_game_scene)

func _on_loaded():
	save_game_mode = SaveGameMode.NONE
	if GameManager.game_data.restoring_scene:
		await get_tree().create_timer(1.0).timeout
		load_persisting_nodes(loaded_restore_index)
		GameManager.unpause()
		SceneManager.transition_out()
		GameManager.game_data.restoring_scene = false

func _remove_all_files():
	var files = DirAccess.get_files_at("user://")
	for file in files:
		if file.begins_with("save_game_"):
			var dir = DirAccess.open("user://")
			dir.remove(file)
		if file.begins_with("save_persisting_nodes_"):
			var dir = DirAccess.open("user://")
			dir.remove(file)

func _find_save_game_index(description: String):
	var index = 1
	var saves = _get_save_games()
	for s in saves:
		if s.description == description:
			return index
		index += 1
	return index

func _get_save_games():
	var saves = []
	for file in DirAccess.get_files_at("user://"):
		if file.begins_with("save_game_"):
			var index = file.get_file().get_basename().get_slice("_", 2)
			var path = str("user://save_game_", index, ".dat")
			var data = GameUtils.restore(path)
			saves.append(data)
	return saves

func _get_next_save_game_index():
	var index = 0
	for file in DirAccess.get_files_at("user://"):
		if file.begins_with("save_game_"):
			var index_str = file.get_file().get_basename().get_slice("_", 2)
			if index_str.is_valid_int():
				index = max(index, index_str.to_int())
	return index + 1

func save(description: String):
	var index = _get_next_save_game_index()
	var path = str("user://save_game_", index, ".dat")
	var data = {
		"index": index,
		"description": description,
		"game_data": GameManager.save(),
		"timestamp": Time.get_datetime_string_from_system(false, true)
	}
	GameUtils.save(path, data)
	save_persisting_nodes(index)
	
func restore(index):
	var path = str("user://save_game_", index, ".dat")
	var data = GameUtils.restore(path)
	GameManager.restore(data)
	if data.game_data.current_scene_path == get_tree().current_scene.scene_file_path:
		load_persisting_nodes(index)
		GameManager.unpause()
	else:
		GameManager.game_data.restoring_scene = true
		SceneManager.goto_scene(data.game_data.current_scene_path)
	save_game_mode = SaveGameMode.NONE
	
func reset():
	GameManager.reset()

func save_persisting_nodes(index):
	var path = str("user://save_persisting_nodes_", index, ".dat")
	var file = FileAccess.open(path, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")
		
#		# Store the save dictionary as a new line in the save file.
		file.store_line(JSON.stringify(node_data))
		
func load_persisting_nodes(index):
	var path = str("user://save_persisting_nodes_", index, ".dat")
	if not FileAccess.file_exists(path):
		return
	var file = FileAccess.open(path, FileAccess.READ)
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	while file.get_position() < file.get_length():
		var json = JSON.new()
		var line = file.get_line()
		# Get the saved dictionary from the next line in the save file
		var error = json.parse(line)
		if error == OK:
			var node_data = json.get_data()
			var node = get_node(node_data.get("path"))
			if node != null:
				var new_position = Vector2(node_data.get("pos_x"), node_data.get("pos_y"))
				node.position = new_position
				# Now we set the remaining variables.
				for i in node_data.keys():
					if i == "filename" or i == "parent" or i == "path" or i == "pos_x" or i == "pos_y" or i == "input_x" or i == "input_y" or i == "movement_direction" or i == "movement_state" or i == "is_facing_right":
						continue
					node.set(i, node_data.get(i))
					
				if node.has_method("restore"):
					node.call("restore", node_data)

				if node.has_method("spawn_restore"):
					node.call("spawn_restore")
#
			#print(node, node_data)
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", line, " at line ", json.get_error_line())
