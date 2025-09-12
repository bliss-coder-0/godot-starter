extends Node2D

@export var cutscene: PackedScene
@export var default_world_path: String

func _ready() -> void:
	var cutscene_node = cutscene.instantiate()
	add_child(cutscene_node)
	cutscene_node.start()
	await get_tree().create_timer(5.0).timeout
	cutscene_node.stop()
	GameManager.game_config.set_state(GameConfig.GAME_STATE.GAME_PLAY)
	SceneManager.goto_scene(default_world_path)
