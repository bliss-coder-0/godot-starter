class_name Spawner extends Node2D

@export var entity_name: String
@export var entity_parent: Node2D
@export var paths: Array[Path2D]

func _ready():
	spawn()
	
func spawn():
	SpawnManager.spawn_paths(entity_name, global_position, paths, entity_parent)
