class_name MoveState extends State
	
func process_physics(delta: float) -> void:
	_move(delta)
	if parent.velocity.length() < 0.1:
		parent.state_machine.dispatch("idle")

func _move(delta: float):
	_apply_gravity(delta)
	_apply_controls(delta)
		
	parent.velocity.y = clamp(parent.velocity.y, -parent.max_velocity.y, parent.max_velocity.y)
	parent.velocity.x = clamp(parent.velocity.x, -parent.max_velocity.x, parent.max_velocity.x)
	
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
			
			# Handle rigid bodies
			if collider is RigidBody2D:
				collider.apply_force(col.get_normal() * -parent.push_force)
				
func _resolve_collision(collision):
	var normal = collision.get_normal()
	var depth = collision.get_depth()
	var travel = collision.get_travel()

	# Calculate the movement needed to resolve the collision
	var move_amount = normal * depth

	# Adjust position considering the original travel direction (optional)
	parent.global_position += move_amount + (travel * 0.1) # Adjust the factor as needed

func _apply_gravity(delta: float):
	parent.velocity += (parent.get_gravity() * parent.gravity_percent) * delta
			
func _apply_controls(_delta: float):
	if parent.paralyzed:
		return
	if parent.is_walking():
		parent.speed = parent.walk_speed
	elif parent.is_running():
		parent.speed = parent.run_speed
		
	var direction = parent.get_movement_direction()
	
	if direction != Vector2.ZERO:
		parent.velocity = parent.velocity.move_toward(direction * parent.speed * parent.movement_percent, parent.acceleration)
	else:
		parent.velocity = parent.velocity.move_toward(Vector2.ZERO, parent.friction)
