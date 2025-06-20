class_name RigidBlock extends RigidBody2D

@export var hp: int = 100
@export var max_hp: int = 100

@export var ap: int = 100
@export var max_ap: int = 100

@export_group("Knockback")
@export var knockback_multiplier: float = 1.0
@export var mass_override: float = -1.0 # -1 means use actual mass, otherwise override
@export var base_knockback_force: float = 50.0 # Base knockback force regardless of velocity

@export_group("Damage")
@export var collision_damage: int = 10
@export var damage_multiplier: float = 1.0
@export var min_damage_velocity: float = 5.0 # Minimum velocity to cause damage
@export var damage_cooldown: float = 1.0 # Time between damage applications

var paralyzed: bool = false

var damage_cooldown_timer: Timer

signal spawned(pos: Vector2)
signal died(pos: Vector2)
signal hp_changed(hp_change: int, max_hp: int)
signal ap_changed(ap_change: int, max_ap: int)

func _ready():
	# Initialize damage cooldown timer
	damage_cooldown_timer = Timer.new()
	damage_cooldown_timer.one_shot = true
	damage_cooldown_timer.wait_time = damage_cooldown
	add_child(damage_cooldown_timer)

func spawn(spawn_position: Vector2 = Vector2.ZERO):
	position = spawn_position
	hp = max_hp
	ap = max_ap
	show()
	spawned.emit(global_position)
	hp_changed.emit(hp, max_hp)
	ap_changed.emit(ap, max_ap)

func die():
	died.emit(global_position)
	call_deferred("queue_free")

func take_damage(amount: int):
	if ap > 0:
		ap -= amount
		ap_changed.emit(ap, max_ap)
		return
	
	hp -= amount

	# Check for death
	if hp <= 0:
		hp_changed.emit(hp, max_hp)
		die()
		return
	
	# Emit current health
	hp_changed.emit(hp, max_hp)

func get_effective_mass() -> float:
	"""Get the mass to use for knockback calculations"""
	if mass_override > 0:
		return mass_override
	return mass if mass > 0 else 1.0

func get_knockback_multiplier() -> float:
	"""Get the knockback multiplier for this block"""
	return knockback_multiplier

func get_knockback_force() -> float:
	"""Get the knockback force based on mass and properties"""
	return base_knockback_force * get_effective_mass() * knockback_multiplier

func should_apply_knockback() -> bool:
	"""Check if this block should apply knockback - always true now"""
	return knockback_multiplier > 0.0

func should_apply_damage() -> bool:
	"""Check if this block should apply damage based on velocity"""
	return linear_velocity.length() >= min_damage_velocity

func can_apply_damage() -> bool:
	"""Check if damage cooldown has expired"""
	return damage_cooldown_timer.is_stopped()

func get_collision_damage() -> int:
	"""Get the damage amount to apply on collision"""
	var base_damage = collision_damage
	var velocity_factor = linear_velocity.length() / 100.0 # Scale damage with velocity
	var final_damage = int(base_damage * damage_multiplier * velocity_factor)
	return max(final_damage, 1) # Minimum 1 damage

func apply_damage_cooldown():
	"""Start the damage cooldown timer"""
	damage_cooldown_timer.start()
