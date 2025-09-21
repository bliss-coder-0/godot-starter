class_name PlayerSpawner extends Node2D

@export var entity_name: String
@export var paths: Array[Path2D]
@export var entity_container: Node2D

var player : CharacterController

func _ready():
	call_deferred("_after_ready")

func _after_ready():
	spawn()
	
func spawn():
	player = SpawnManager.spawn_paths(entity_name, global_position, paths, entity_container)
	EventBus.player_spawned.emit(player)
