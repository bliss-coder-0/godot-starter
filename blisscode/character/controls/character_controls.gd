class_name CharacterControls extends Node

enum AimType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH, AI}
enum MovementType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH, AI}
enum FacingType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH, AI}
enum AttackType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH, AI}

@export var movement_type: MovementType = MovementType.DEFAULT
@export var aim_type: AimType = AimType.DEFAULT
@export var facing_type: FacingType = FacingType.DEFAULT
@export var attack_type: AttackType = AttackType.DEFAULT

var parent: CharacterController

func _ready() -> void:
	parent = get_parent()

func get_movement_direction() -> Vector2:
	return Vector2.ZERO

func get_aim_direction() -> Vector2:
	return Vector2.ZERO

func get_facing_direction():
	return Vector2.RIGHT if parent.is_facing_right else Vector2.LEFT

func get_double_tap_direction() -> Vector2:
	return Vector2.ZERO

func is_walking() -> bool:
	return false

func is_running() -> bool:
	return false

func is_action_just_pressed(_action_name) -> bool:
	return false

func is_action_pressed(_action_name) -> bool:
	return false
