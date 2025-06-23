class_name CharacterControls extends Node

func get_movement_direction() -> Vector2:
	return Vector2.ZERO

func get_aim_direction() -> Vector2:
	return Vector2.ZERO

func get_facing_direction() -> Vector2:
	return Vector2.RIGHT

func is_walking() -> bool:
	return false

func is_running() -> bool:
	return false
