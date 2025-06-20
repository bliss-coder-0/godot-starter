extends Node2D

@export var entities: Dictionary[String, PackedScene]

func spawn(entity_name: String, spawn_position: Vector2, parent: Node = null):
	if entities.has(entity_name):
		var entity = entities[entity_name].instantiate()
		entity.position = spawn_position
		if entity is CharacterController:
			entity.spawn(spawn_position)
		if parent:
			parent.add_child(entity)
		else:
			SceneManager.current_scene.add_child(entity)
		return entity
	return null
