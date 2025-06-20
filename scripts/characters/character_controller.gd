@tool
class_name CharacterController extends CharacterBody2D

enum CharacterType {PLAYER, NPC}
enum AimType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH}
enum MovementType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH}
enum FacingType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH}
enum AttackType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH}

@onready var state_machine: StateMachine = $StateMachine

@export var character_name: String = "Player"
@export var character_type: CharacterType = CharacterType.PLAYER

@export_group("Controls")
@export var movement_type: MovementType = MovementType.DEFAULT
@export var aim_type: AimType = AimType.DEFAULT
@export var facing_type: FacingType = FacingType.DEFAULT
@export var attack_type: AttackType = AttackType.DEFAULT

@export_tool_button("Mobile", "Callable") var mobile_action = mobile_controls

func mobile_controls():
	aim_type = AimType.TOUCH
	movement_type = MovementType.TOUCH
	facing_type = FacingType.TOUCH
	attack_type = AttackType.TOUCH

@export_tool_button("Console", "Callable") var console_action = console_controls

func console_controls():
	aim_type = AimType.JOYSTICK
	movement_type = MovementType.JOYSTICK
	facing_type = FacingType.JOYSTICK
	attack_type = AttackType.JOYSTICK

@export_tool_button("PC", "Callable") var pc_action = pc_controls

func pc_controls():
	aim_type = AimType.MOUSE
	movement_type = MovementType.KEYBOARD
	facing_type = FacingType.MOUSE
	attack_type = AttackType.MOUSE

@export_group("Movement")
@export var walk_speed: float = 100.0
@export var run_speed: float = 300.0
@export var max_velocity: Vector2 = Vector2(1000, 1000)
@export var allow_y_controls: bool = false

@export_group("Forces")
@export var acceleration: float = 75.0
@export var friction: float = 30.0
@export var push_force: float = 300.0
@export var dash_force: float = 600.0

@export_group("Modifiers")
@export var movement_percent: float = 1.0
@export var gravity_percent: float = 1.0

@export_group("Weapon Bases")
@export var weapon_primary: RangedWeaponBase
@export var weapon_secondary: RangedWeaponBase

@export_group("Navigation")
@export var navigation_agent: NavigationAgent2D

@export_group("Health")
@export var hp: int = 100
@export var max_hp: int = 100

@export_group("Armor")
@export var ap: int = 100
@export var max_ap: int = 100

@export_group("Debug")
@export var aim_sprite: Sprite2D
@export var show_aim_sprite: bool = true
@export var touch_sprite: Sprite2D
@export var show_touch_sprite: bool = true

var touch_position: Vector2 = Vector2.ZERO
var is_touching: bool = false

var speed: float = 300.0
var was_facing_right = true
var is_facing_right = true

var double_tap_timer: Timer = null
var double_tap_time: float = 0.3 # Adjust as needed
var double_tap_count: int = 0
var last_pressed_movement: String = ""

var paralyzed: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if touch_sprite != null:
		touch_sprite.hide()
	double_tap_timer = Timer.new()
	double_tap_timer.one_shot = true
	double_tap_timer.wait_time = double_tap_time
	add_child(double_tap_timer)
	double_tap_timer.connect("timeout", self._on_double_tap_timeout)
	
	if navigation_agent:
		navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func _on_velocity_computed(safe_velocity: Vector2):
	if Engine.is_editor_hint():
		return
	velocity = safe_velocity

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if Input.is_action_just_pressed('dash') and not paralyzed:
		state_machine.dispatch("dash")
	elif event is InputEventScreenTouch and event.double_tap and attack_type == AttackType.TOUCH:
		touch_position = to_world_position(event.position)
		_attack_secondary()
	elif event is InputEventScreenDrag:
		touch_position = to_world_position(event.position)
		if touch_sprite != null:
			touch_sprite.global_position = touch_position
		is_touching = true
	elif event is InputEventScreenTouch and event.pressed:
		touch_position = to_world_position(event.position)
		if touch_sprite != null:
			touch_sprite.global_position = touch_position
		if show_touch_sprite and touch_sprite != null:
			touch_sprite.show()
		is_touching = true
	elif event is InputEventScreenTouch and not event.pressed:
		touch_position = Vector2.ZERO
		if touch_sprite != null:
			touch_sprite.hide()
			touch_sprite.global_position = touch_position
		is_touching = false
		
func _double_tap_dash():
	if paralyzed:
		return
	# Check for movement button presses
	var current_movement = ""
	if Input.is_action_just_pressed("move_left"):
		current_movement = "move_left"
	elif Input.is_action_just_pressed("move_right"):
		current_movement = "move_right"
	elif Input.is_action_just_pressed("move_up"):
		current_movement = "move_up"
	elif Input.is_action_just_pressed("move_down"):
		current_movement = "move_down"
		
	if current_movement != "":
		if double_tap_timer.is_stopped():
			last_pressed_movement = current_movement
			double_tap_count = 1
			double_tap_timer.start()
		else:
			if double_tap_count == 1 and current_movement == last_pressed_movement:
				state_machine.dispatch("dash")
				double_tap_count = 0
				double_tap_timer.stop()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_attack()
	_update_aim_sprite()
	_double_tap_dash()
	_update_facing_direction()

func _update_aim_sprite():
	if aim_sprite != null:
		aim_sprite.global_position = weapon_primary.global_position + get_aim_direction() * 50
		if show_aim_sprite:
			aim_sprite.show()
		else:
			aim_sprite.hide()

func _update_facing_direction():
	if facing_type == FacingType.MOUSE:
		var mouse_pos = get_global_mouse_position()
		if mouse_pos.x < position.x:
			was_facing_right = false
		else:
			was_facing_right = true
	elif facing_type == FacingType.TOUCH:
		if touch_position != Vector2.ZERO:
			if touch_position.x < global_position.x:
				was_facing_right = false
			else:
				was_facing_right = true
	elif facing_type == FacingType.KEYBOARD:
		if velocity.x < 0:
			was_facing_right = false
		elif velocity.x > 0:
			was_facing_right = true
	elif facing_type == FacingType.JOYSTICK:
		if velocity.x < 0:
			was_facing_right = false
		elif velocity.x > 0:
			was_facing_right = true
	elif facing_type == FacingType.DEFAULT:
		if velocity.x < 0:
			was_facing_right = false
		elif velocity.x > 0:
			was_facing_right = true
	if is_facing_right != was_facing_right:
		_handle_flip()

func _handle_flip():
	is_facing_right = !is_facing_right
	scale.x *= -1

func get_facing_direction():
	return Vector2.RIGHT if is_facing_right else Vector2.LEFT

func get_aim_direction():
	if aim_type == AimType.DEFAULT:
		return get_default_aim_direction()
	elif aim_type == AimType.TOUCH:
		return get_touch_aim_direction()
	elif aim_type == AimType.MOUSE:
		return get_mouse_aim_direction()
	elif aim_type == AimType.KEYBOARD:
		return get_keyboard_aim_direction()
	elif aim_type == AimType.JOYSTICK:
		return get_joystick_aim_direction()

func get_default_aim_direction():
	return get_facing_direction().normalized()

func get_touch_aim_direction():
	if touch_position == Vector2.ZERO:
		return get_facing_direction()
	var direction = touch_position - global_position
	return direction.normalized()

func get_mouse_aim_direction():
	var direction = get_global_mouse_position() - weapon_primary.global_position
	return direction.normalized()

func get_keyboard_aim_direction():
	var direction: Vector2 = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	).normalized()
	if direction.length() < 0.1:
		return get_facing_direction()
	return direction

func get_joystick_aim_direction():
	var direction: Vector2 = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	).normalized()
	if direction.length() < 0.1:
		return get_facing_direction()
	return direction

func get_movement_direction():
	if paralyzed:
		return Vector2.ZERO
	if movement_type == MovementType.DEFAULT:
		return get_default_movement_direction()
	elif movement_type == MovementType.MOUSE:
		return get_mouse_movement_direction()
	elif movement_type == MovementType.KEYBOARD:
		return get_keyboard_movement_direction()
	elif movement_type == MovementType.JOYSTICK:
		return get_joystick_movement_direction()
	elif movement_type == MovementType.TOUCH:
		return get_touch_movement_direction()

func get_default_movement_direction():
	var direction: Vector2 = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	return direction

func get_mouse_movement_direction():
	var direction = get_global_mouse_position() - global_position
	return direction.normalized()

func get_keyboard_movement_direction():
	var direction: Vector2 = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	return direction

func get_joystick_movement_direction():
	var direction: Vector2 = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	return direction

func get_touch_movement_direction():
	if touch_position == Vector2.ZERO:
		return Vector2.ZERO
	var direction = touch_position - global_position
	return direction.normalized()

func is_walking() -> bool:
	return not Input.is_action_pressed("run") and get_movement_direction() != Vector2.ZERO

func is_running() -> bool:
	return Input.is_action_pressed("run") and get_movement_direction() != Vector2.ZERO
		
func is_attacking():
	return Input.is_action_pressed("attack_primary") or Input.is_action_pressed("attack_secondary")

func is_action_just_pressed(action_name) -> bool:
	return Input.is_action_just_pressed(action_name)

func is_action_pressed(action_name) -> bool:
	return Input.is_action_pressed(action_name)
	
func is_movement_pressed() -> bool:
	return get_movement_direction() != Vector2.ZERO

func _on_double_tap_timeout():
	double_tap_count = 0
	
func to_world_position(screen_position: Vector2) -> Vector2:
	var canvas_transform = get_viewport().get_canvas_transform()
	var world_position = canvas_transform.affine_inverse() * screen_position
	return world_position

func _attack():
	if attack_type == AttackType.TOUCH:
		if is_touching:
			_attack_primary()
	else:
			if Input.is_action_pressed("attack_primary"):
				_attack_primary()
			elif Input.is_action_pressed("attack_secondary"):
				_attack_secondary()

func _attack_primary():
	if paralyzed:
		return
	if weapon_primary != null:
		weapon_primary.attack(get_aim_direction())
	
func _attack_secondary():
	if paralyzed:
		return
	if weapon_secondary != null:
		weapon_secondary.attack(get_aim_direction())

func spawn(pos: Vector2 = position):
	position = pos
	paralyzed = false
	
func spawn_restore():
	velocity.x = 0
	velocity.y = 0
	paralyzed = false
	
func spawn_random_from_nav():
	if navigation_agent:
		var map = navigation_agent.get_navigation_map()
		if map == null:
			return
		var random_point = NavigationServer2D.map_get_random_point(map, 1, false)
		spawn(random_point)
	else:
		spawn(position)
		
func paralyze():
	paralyzed = true
	velocity = Vector2.ZERO

func save():
	var data = {
		"filename": get_scene_file_path(),
		"path": get_path(),
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"was_facing_right": was_facing_right,
		"is_facing_right": is_facing_right
	}
	return data
	
func restore(data):
	if data.has("was_facing_right"):
		was_facing_right = data.get("was_facing_right")
	if data.has("is_facing_right"):
		is_facing_right = data.get("is_facing_right")
	if data.has("pos_x"):
		position.x = data.get("pos_x")
	if data.has("pos_y"):
		position.y = data.get("pos_y")
