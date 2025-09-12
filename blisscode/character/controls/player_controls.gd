@tool
class_name PlayerControls extends CharacterControls

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

@export_group("Debug")
@export var aim_sprite: Sprite2D
@export var show_aim_sprite: bool = true
@export var touch_sprite: Sprite2D
@export var show_touch_sprite: bool = true

func pc_controls():
	aim_type = AimType.MOUSE
	movement_type = MovementType.KEYBOARD
	facing_type = FacingType.MOUSE
	attack_type = AttackType.MOUSE

var touch_position: Vector2 = Vector2.ZERO
var is_touching: bool = false

enum DOUBLE_TAP_DIRECTION {NONE, LEFT, RIGHT, UP, DOWN}

var double_tap_direction = DOUBLE_TAP_DIRECTION.NONE
var double_tap_timer: Timer = null
var double_tap_time: float = 0.3
var double_tap_count: int = 0
var last_pressed_movement: String = ""

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super ()
	double_tap_timer = Timer.new()
	double_tap_timer.one_shot = true
	double_tap_timer.wait_time = double_tap_time
	double_tap_timer.connect("timeout", _on_double_tap_timeout)
	add_child(double_tap_timer)
	
func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventScreenTouch and event.double_tap and attack_type == AttackType.TOUCH:
		touch_position = to_world_position(event.position)
		#_attack_right_hand()
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
		
func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_update_aim_sprite()
	_double_tap_dash()
	if attack_type == AttackType.TOUCH:
		if is_touching:
			simulate_button_press("attack_left_hand")

func _double_tap_dash():
	if parent.paralyzed:
		return
	var current_movement = ""
	if is_action_just_pressed("move_left"):
		current_movement = "move_left"
	elif is_action_just_pressed("move_right"):
		current_movement = "move_right"
	elif is_action_just_pressed("move_up"):
		current_movement = "move_up"
	elif is_action_just_pressed("move_down"):
		current_movement = "move_down"
		
	if current_movement != "":
		match current_movement:
			"move_left":
				double_tap_direction = DOUBLE_TAP_DIRECTION.LEFT
			"move_right":
				double_tap_direction = DOUBLE_TAP_DIRECTION.RIGHT
			"move_up":
				double_tap_direction = DOUBLE_TAP_DIRECTION.UP
			"move_down":
				double_tap_direction = DOUBLE_TAP_DIRECTION.DOWN
		if double_tap_timer.is_stopped():
			last_pressed_movement = current_movement
			double_tap_count = 1
			double_tap_timer.start()
		else:
			if double_tap_count == 1 and current_movement == last_pressed_movement:
				simulate_button_press("dash")
				double_tap_count = 0
				double_tap_timer.stop()

func _on_double_tap_timeout():
	double_tap_count = 0

func get_double_tap_direction():
	match double_tap_direction:
		DOUBLE_TAP_DIRECTION.LEFT:
			return Vector2.LEFT
		DOUBLE_TAP_DIRECTION.RIGHT:
			return Vector2.RIGHT
		DOUBLE_TAP_DIRECTION.UP:
			return Vector2.UP
		DOUBLE_TAP_DIRECTION.DOWN:
			return Vector2.DOWN

func simulate_button_press(action_name: String):
	var press = InputEventAction.new()
	press.action = action_name
	press.pressed = true
	Input.parse_input_event(press)

	var release = InputEventAction.new()
	release.action = action_name
	release.pressed = false
	Input.parse_input_event(release)

func _update_aim_sprite():
	if aim_sprite != null:
		aim_sprite.global_position = parent.global_position + get_aim_direction() * 50
		if show_aim_sprite:
			aim_sprite.show()
		else:
			aim_sprite.hide()

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
	var direction = touch_position - parent.global_position
	return direction.normalized()

func get_mouse_aim_direction():
	var direction = parent.get_global_mouse_position() - parent.global_position
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
	if parent.paralyzed:
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
	var direction = parent.get_global_mouse_position() - parent.global_position
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
	var direction = touch_position - parent.global_position
	return direction.normalized()

func is_walking() -> bool:
	return not Input.is_action_pressed("run") and get_movement_direction() != Vector2.ZERO

func is_running() -> bool:
	return Input.is_action_pressed("run") and get_movement_direction() != Vector2.ZERO
		
func is_attacking_left_hand():
	return Input.is_action_pressed("attack_left_hand")

func is_attacking_right_hand():
	return Input.is_action_pressed("attack_right_hand")

func is_action_just_pressed(action_name) -> bool:
	return Input.is_action_just_pressed(action_name)

func is_action_pressed(action_name) -> bool:
	return Input.is_action_pressed(action_name)
	
func is_movement_pressed() -> bool:
	return get_movement_direction() != Vector2.ZERO

func to_world_position(screen_position: Vector2) -> Vector2:
	var canvas_transform = get_viewport().get_canvas_transform()
	var world_position = canvas_transform.affine_inverse() * screen_position
	return world_position
