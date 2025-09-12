extends Node2D

@export var cutscene: PackedScene

func _ready() -> void:
	var cutscene_node = cutscene.instantiate()
	add_child(cutscene_node)
	cutscene_node.start()
	await get_tree().create_timer(5.0).timeout
	cutscene_node.stop()
	GameManager.game_config.set_state(GameConfig.GAME_STATE.GAME_RESTORE)
	var restore_data = UserDataStore.get_restore_data()
	print("restore_data", restore_data)
	#var restore_world_path = restore_data.restore_world_path
	#SceneManager.goto_scene(restore_world_path)
