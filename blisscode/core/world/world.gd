class_name World extends Node2D

@export var world_name: String

var world_doors: Array[WorldDoor] = []

func _ready() -> void:
	_find_world_doors(self)
	
	if GameManager.game_config.game_state == GameConfig.GAME_STATE.GAME_RESTORE:
		_restore_spwan()
	else:
		_default_spawn()
	
	GameUi.hud.show_hud()
	
func _restore_spwan():
	print("Restore")
	GameManager.game_config.set_state(GameConfig.GAME_STATE.GAME_PLAY)
	
func _default_spawn():
	var world_door_spawn = null
	if world_door_spawn:
		world_door_spawn.spawn_player()
	GameManager.game_config.set_state(GameConfig.GAME_STATE.GAME_PLAY)
	
func _find_world_doors(node: Node):
	if node is WorldDoor:
		world_doors.append(node)
	for child in node.get_children():
		_find_world_doors(child)

func find_world_door():
	for door in world_doors:
		if door.door_id == GameManager.game_config.to_world_door_id:
			return door
	return null

func save():
	return {
		"filename": get_scene_file_path(),
		"path": get_path(),
		"parent": get_parent().get_path(),
	}
