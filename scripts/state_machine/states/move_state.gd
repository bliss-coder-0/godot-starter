class_name MoveState extends State
	
func process_physics(delta: float) -> void:
	_move(delta)
	if parent.velocity.length() < 0.1:
		parent.state_machine.dispatch("idle")

func _move(delta: float):
	_apply_gravity(delta)
	_apply_controls(delta)
		
	parent.velocity.y = clamp(parent.velocity.y, -PhysicsManager.max_velocity.y, PhysicsManager.max_velocity.y)
	parent.velocity.x = clamp(parent.velocity.x, -PhysicsManager.max_velocity.x, PhysicsManager.max_velocity.x)
	
	var has_collisions = parent.move_and_slide()

	if has_collisions:
		for i in parent.get_slide_collision_count():
			var col = parent.get_slide_collision(i)
			
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
				collider.apply_force(col.get_normal() * -PhysicsManager.push_force)
								
func _resolve_collision(collision):
	var normal = collision.get_normal()
	var depth = collision.get_depth()
	var travel = collision.get_travel()

	# Calculate the movement needed to resolve the collision
	var move_amount = normal * depth

	# Adjust position considering the original travel direction (optional)
	parent.global_position += move_amount + (travel * 0.1) # Adjust the factor as needed

func _apply_gravity(delta: float):
	parent.velocity += (parent.get_gravity() * PhysicsManager.gravity_percent) * delta
			
func _apply_controls(_delta: float):
	if parent.paralyzed:
		return
	if parent.controls.is_walking():
		parent.speed = parent.walk_speed
	elif parent.controls.is_running():
		parent.speed = parent.run_speed
		
	var direction = parent.controls.get_movement_direction()
	
	if direction != Vector2.ZERO:
		parent.velocity = parent.velocity.move_toward(direction * parent.speed * parent.movement_percent, PhysicsManager.acceleration)
	else:
		parent.velocity = parent.velocity.move_toward(Vector2.ZERO, PhysicsManager.friction)

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
	#knockback_force *= PhysicsManager.knockback_resistance
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
