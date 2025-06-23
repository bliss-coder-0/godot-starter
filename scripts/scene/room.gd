class_name Room extends Node2D

@export var camera: Camera2D
@export var player: CharacterController
@export var spawn_at_first_door: bool = false
@export var room_state: Dictionary[String, bool]

var room_doors: Array[RoomDoor] = []
var prev_room_door: RoomDoor = null
var current_room_door: RoomDoor = null
var default_room_state: Dictionary[String, bool] = {}

func _ready() -> void:
	default_room_state = room_state
	camera.enabled = false
	room_doors = []
	_find_room_doors(self)
	
	if not GameManager.game_data.restoring_scene:
		if GameManager.game_data.prev_door_id != "":
			prev_room_door = get_room_door_by_id(GameManager.game_data.prev_door_id)
		
		if GameManager.game_data.current_door_id == "" and spawn_at_first_door:
			current_room_door = get_room_door_by_id("1")
		else:
			current_room_door = get_room_door_by_id(GameManager.game_data.current_door_id)
		
		if current_room_door:
			current_room_door.spawn_player(player)

		_spawn_npc_characters()
		
	call_deferred("_has_loaded")

func _spawn_npc_characters():
	for c in get_children():
		if c is CharacterController:
			if c.character_sheet.character_type == CharacterSheet.CharacterControllerType.NPC:
				c.spawn_random()

func _has_loaded():
	camera.enabled = true
	camera.make_current()

func get_room_door_by_id(id: String) -> RoomDoor:
	for door in room_doors:
		if door.door_id == id:
			return door
	return null

func _find_room_doors(node: Node):
	if node is RoomDoor:
		room_doors.append(node)
	for child in node.get_children():
		_find_room_doors(child)

func save():
	var data = {
		"filename": get_scene_file_path(),
		"path": get_path(),
		"parent": get_parent().get_path(),
		"room_state": room_state,
		"pos_x": position.x,
		"pos_y": position.y
	}
	return data
	
func restore(data):
	if data.has("room_state"):
		var data_room_state = data.get("room_state", default_room_state)
		for key in data_room_state.keys():
			room_state[key] = data_room_state[key]
