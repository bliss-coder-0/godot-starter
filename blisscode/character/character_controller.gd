class_name CharacterController extends CharacterBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D

@export var character_sheet: CharacterSheet
@export var inventory: Inventory
@export var equipment: Equipment
@export var controls: CharacterControls

@export_group("Movement")
@export var speed: float = 100.0
@export var walk_multiplier: float = 1
@export var run_multiplier: float = 3
@export var jump_force: float = 100.0
@export var has_navigation: bool = false
@export var allow_y_controls: bool = false
@export var movement_percent: float = 1.0
@export var movement_lerp: bool = true

@export_group("Physics")
@export var gravity_percent: float = 1.0
@export var acceleration: float = 50.0
@export var friction: float = 15.0
@export var push_force: float = 300.0
@export var knockback_force: float = 200.0
@export var knockback_resistance: float = 0.5
@export var max_velocity: Vector2 = Vector2(1000.0, 1000.0)

@export_group("Navigation")
@export var navigation_agent: NavigationAgent2D
@export var paths: Array[Path2D]

@export_group("Garbage")
@export var garbage: bool = false
@export var garbage_time: float = 0.0

@export_group("Dash")
@export var dash_time: float = 0.5
@export var dash_speed_multiplier: float = 10.0
@export var stop_on_end: bool = false

@export_group("Behavior Trees")
@export var behavior_trees: Array[BTPlayer] = []

var dash_time_elapsed: float = 0

var was_facing_right = true
var is_facing_right = true
var paralyzed: bool = false
var cooldown_left_hand = false
var cooldown_right_hand = false
var attack_rate_time_elapsed_left_hand = 0
var attack_rate_time_elapsed_right_hand = 0
var attack_rate_left_hand = 0
var attack_rate_right_hand = 0
var original_speed: float
var time_scale: float = 1.0
var is_jumping: bool = false

signal spawned(pos: Vector2)
signal died(character: CharacterController)
signal ammo_changed(item: Item, ammo: int)

func _ready() -> void:
	original_speed = speed
	if navigation_agent:
		navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	velocity = Vector2.ZERO
	paralyzed = false
	spawned.emit(global_position)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		dash_towards_controls_direction()
	elif event.is_action_pressed("jump"):
		jump()

func _process(delta: float) -> void:
	attack_rate_time_elapsed_left_hand += delta
	if attack_rate_time_elapsed_left_hand <= attack_rate_left_hand:
		cooldown_left_hand = true
	else:
		cooldown_left_hand = false
	attack_rate_time_elapsed_right_hand += delta
	if attack_rate_time_elapsed_right_hand <= attack_rate_right_hand:
		cooldown_right_hand = true
	else:
		cooldown_right_hand = false

func _physics_process(delta: float) -> void:
	velocity += apply_gravity(delta)
	
	if not has_navigation:
		var direction = controls.get_movement_direction()
		if controls.is_walking():
			speed = original_speed * walk_multiplier
		elif controls.is_running():
			speed = original_speed * run_multiplier
			time_scale = run_multiplier
		else:
			speed = original_speed
			time_scale = 1.0
		
		# Apply input movement to existing velocity
		velocity = self.move_toward(direction, speed)

	clamp_velocity()

	if move_and_slide():
		handle_collisions()

	if controls.is_attacking_left_hand():
		attack_left_hand()
	
	if controls.is_attacking_right_hand():
		attack_right_hand()

	dash_time_elapsed += delta
	if dash_time_elapsed >= dash_time and stop_on_end:
		stop()

	_update_animation_tree()
	_update_facing_direction()

	if is_on_floor():
		is_jumping = false

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	clamp_velocity()

func _update_animation_tree():
	if animation_tree and controls:
		var looking_at = controls.get_aim_direction()
		animation_tree.set("parameters/PlayerStates/Idle/blend_position", looking_at)
		animation_tree.set("parameters/PlayerStates/Walk/blend_position", looking_at)
		animation_tree.set("parameters/PlayerStates/Jump/blend_position", looking_at)
		animation_tree.set("parameters/TimeScale/scale", time_scale)
		
func change_to_position(new_position: Vector2 = Vector2.ZERO):
	position = new_position

func spawn(spawn_position: Vector2 = Vector2.ZERO):
	position = spawn_position
	spawned.emit(global_position)
	focus()

func spawn_restore():
	velocity.x = 0
	velocity.y = 0
	paralyzed = false
	spawned.emit(global_position)
	
func spawn_random_from_nav():
	if navigation_agent:
		var map = navigation_agent.get_navigation_map()
		if map == null:
			return
		var random_point = NavigationServer2D.map_get_random_point(map, 1, false)
		position = random_point
		spawned.emit(global_position)
	else:
		position = position
		spawned.emit(global_position)
		
func paralyze():
	paralyzed = true
	velocity = Vector2.ZERO

func die():
	died.emit(self)
	paralyzed = true
	if garbage:
		await get_tree().create_timer(garbage_time).timeout
		call_deferred("queue_free")
	else:
		await get_tree().create_timer(garbage_time).timeout
		hide()
	
func apply_gravity(delta: float):
	return (get_gravity() * gravity_percent) * delta

func jump():
	if is_on_floor():
		velocity.y = - jump_force
		is_jumping = true

func move_toward(direction: Vector2, s: float):
	var result_velocity = velocity
	
	if movement_lerp:
		if direction != Vector2.ZERO:
			# Calculate target velocity using the whole direction vector
			var target_velocity = direction * s * movement_percent
			if not allow_y_controls:
				# Only preserve vertical velocity (gravity) if y controls are disabled
				target_velocity.y = velocity.y
			result_velocity = result_velocity.move_toward(target_velocity, acceleration)
		else:
			# Apply friction, preserving vertical velocity if y controls are disabled
			var target_velocity = Vector2.ZERO
			if not allow_y_controls:
				target_velocity.y = velocity.y
			result_velocity = result_velocity.move_toward(target_velocity, friction)
	else:
		if direction != Vector2.ZERO:
			result_velocity = direction * s * movement_percent
			if not allow_y_controls:
				result_velocity.y = velocity.y
		else:
			result_velocity = Vector2.ZERO
			if not allow_y_controls:
				result_velocity.y = velocity.y
	return result_velocity
		
func clamp_velocity():
	velocity = velocity.clamp(-max_velocity, max_velocity)
							
func stop():
	velocity = Vector2.ZERO

func handle_collisions():
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		
		_resolve_collision(col)
		
		var collider = col.get_collider()
					
		# Handle collision damage from enemies
		#var collision = get_last_slide_collision()
		#var collider = collision.get_collider()
		#if collider.is_in_group("enemy"):
			#take_damage_from_node(collider)
		
		#if collider is RigidBlock:
			#if _apply_knockback(collider, col):
				#_apply_collision_damage(collider)
			#else:
		if collider is RigidBody2D:
			collider.apply_force(col.get_normal() * -push_force)
				
func _resolve_collision(collision):
	var normal = collision.get_normal()
	var depth = collision.get_depth()
	var travel = collision.get_travel()

	# Calculate the movement needed to resolve the collision
	var move_amount = normal * depth

	# Adjust position considering the original travel direction (optional)
	global_position += move_amount + (travel * 0.1) # Adjust the factor as needed

#func _apply_knockback(rigid_body: RigidBlock, collision: KinematicCollision2D):
	## Check if the rigid block should apply knockback
	#if not rigid_body.should_apply_knockback():
		#return false
		#
	## Get knockback force from the rigid block
	#var knockback_strength = rigid_body.get_knockback_force()
	#
	## Apply knockback in the direction of the collision normal
	#var knockback_direction = collision.get_normal()
	#var knockback_force = knockback_direction * knockback_strength
	#
	## Apply resistance to reduce knockback effect
	#knockback_force *= knockback_resistance
	#
	## Apply the knockback to the player's velocity
	#parent.velocity += knockback_force
	#
	## Optional: Add some upward force for more dramatic effect
	#if knockback_strength > 50.0:
		#parent.velocity.y -= knockback_strength * 0.3
#
	#return true
#
#func _apply_collision_damage(rigid_body: RigidBlock):
	## Check if the rigid block should apply damage
	#if not rigid_body.should_apply_damage():
		#return
		#
	## Check if damage cooldown has expired
	#if not rigid_body.can_apply_damage():
		#return
		#
	## Get the damage amount from the rigid block
	#var damage_amount = rigid_body.get_collision_damage()
	#
	## Apply damage to the player
	#parent.take_damage(damage_amount)
	#
	## Start the damage cooldown on the rigid block
	#rigid_body.apply_damage_cooldown()
	#
	## Optional: Add visual/audio feedback
	## You can add screen shake, sound effects, or particle effects here
	#if parent.has_method("_on_take_damage"):
		#parent._on_take_damage(damage_amount)

func _update_facing_direction():
	if controls.facing_type == CharacterControls.FacingType.MOUSE:
		var mouse_pos = get_global_mouse_position()
		is_facing_right = mouse_pos.x > position.x
	elif controls.facing_type == CharacterControls.FacingType.TOUCH:
		is_facing_right = controls.touch_position.x > global_position.x
	elif controls.facing_type == CharacterControls.FacingType.KEYBOARD:
		is_facing_right = velocity.x > 0
	elif controls.facing_type == CharacterControls.FacingType.JOYSTICK:
		is_facing_right = velocity.x > 0
	elif controls.facing_type == CharacterControls.FacingType.DEFAULT:
		is_facing_right = velocity.x > 0
	_handle_flip()

func _handle_flip():
	sprite.flip_h = not is_facing_right
	
func face_direction(_direction: Vector2):
	pass

func take_damage(amount: int):
	character_sheet.take_damage(amount)
	if character_sheet.health <= 0:
		die()

func item_pickup(item: Item, pos: Vector2):
	if item is Currency:
		inventory.add_gold(item.amount, pos)
	elif item is Equipable:
		equip(item, pos)
	elif item is Consumable:
		consume(item, pos)

func consume(item: Item, pos: Vector2):
	if item.consume_on_pickup:
		if item.health > 0:
			character_sheet.add_health(item.health)
		if item.mana > 0:
			character_sheet.add_mana(item.mana)
		if item.stamina > 0:
			character_sheet.add_stamina(item.stamina)
	else:
		inventory.add(item.id, pos)

func equip(item: Item, pos: Vector2):
	if item.equip_on_pickup:
		equipment.equip(item.id, equipment.get_next_available_slot(item.slot))
	else:
		inventory.add(item.id, pos)

func attack_left_hand():
	if cooldown_left_hand:
		return
	var left_hand = equipment.left_hand
	if left_hand is RangedWeapon:
		attack_rate_left_hand = left_hand.attack_rate
		attack_rate_time_elapsed_left_hand = 0
		attack_ranged_weapon(left_hand, controls.get_aim_direction())

func attack_right_hand():
	if cooldown_right_hand:
		return
	var right_hand = equipment.right_hand
	if right_hand is RangedWeapon:
		attack_rate_right_hand = right_hand.attack_rate
		attack_rate_time_elapsed_right_hand = 0
		attack_ranged_weapon(right_hand, controls.get_aim_direction())

func attack_ranged_weapon(item: RangedWeapon, direction: Vector2):
	if (!item.unlimited_ammo and item.ammo <= 0):
		return
	if not item.unlimited_ammo:
		item.ammo -= 1
	SpawnManager.spawn_projectile(item.projectile, global_position, direction)
	ammo_changed.emit(item, item.ammo)

func focus():
	if camera:
		camera.enabled = true
		camera.make_current()

func dash_towards_controls_direction():
	dash_time_elapsed = 0
	var direction = Vector2.ZERO
	if controls.double_tap_direction != controls.DOUBLE_TAP_DIRECTION.NONE:
		direction = controls.get_double_tap_direction()
		controls.double_tap_direction = controls.DOUBLE_TAP_DIRECTION.NONE
	else:
		direction = controls.get_aim_direction()
	velocity += direction * speed * dash_speed_multiplier

func save():
	var behavior_trees_data = []
	for tree in behavior_trees:
		behavior_trees_data.append(tree.save())
	var path_progress_ratios = []
	for path in paths:
		var follow = path.get_node("PathFollow2D")
		path_progress_ratios.append(follow.progress_ratio)
	var data = {
		"filename": get_scene_file_path(),
		"path": get_path(),
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"rotation": rotation,
		"velocity_x": velocity.x,
		"velocity_y": velocity.y,
		"is_facing_right": is_facing_right,
		"behavior_trees": behavior_trees_data,
		"path_progress_ratios": path_progress_ratios,
		#"character_sheet": character_sheet.save(),
		#"inventory": inventory.save()
	}
	return data
	
func restore(data):
	if data.has("is_facing_right"):
		is_facing_right = data.get("is_facing_right")
	if data.has("pos_x"):
		position.x = data.get("pos_x")
	if data.has("pos_y"):
		position.y = data.get("pos_y")
	if data.has("rotation"):
		rotation = data.get("rotation")
	if data.has("velocity_x"):
		velocity.x = data.get("velocity_x")
	if data.has("velocity_y"):
		velocity.y = data.get("velocity_y")
	if data.has("behavior_trees"):
		for tree_data in data.get("behavior_trees"):
			for tree in behavior_trees:
				tree.restore(tree_data)
	if data.has("path_progress_ratios"):
		for path_data in data.get("path_progress_ratios"):
			for path in paths:
				var follow = path.get_node("PathFollow2D")
				follow.progress_ratio = path_data
	#if data.has("character_sheet"):
		#character_sheet.restore(data.get("character_sheet"))
	#if data.has("inventory"):
		#inventory.restore(data.get("inventory"))
