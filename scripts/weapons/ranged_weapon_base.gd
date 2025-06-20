class_name RangedWeaponBase extends Node2D

@export var ranged_weapon: RangedWeapon

var fire_rate_time_elapsed: float = 0.0
var cooldown = false

signal ammo_changed(ammo: int)

func _process(delta: float) -> void:
	fire_rate_time_elapsed += delta
	if fire_rate_time_elapsed <= ranged_weapon.fire_rate:
		cooldown = true
	else:
		cooldown = false

func attack(direction: Vector2):
	if not can_attack():
		return
	if not ranged_weapon.unlimited_ammo:
		ranged_weapon.ammo -= 1
	fire_rate_time_elapsed = 0
	var b = ranged_weapon.projectile.instantiate()
	b.start(global_position, direction)
	get_tree().get_root().add_child(b)
	ammo_changed.emit(ranged_weapon.ammo)

func add_ammo(amount: int):
	ranged_weapon.ammo += amount
	if ranged_weapon.ammo >= ranged_weapon.max_ammo:
		ranged_weapon.ammo = ranged_weapon.max_ammo
	ammo_changed.emit(ranged_weapon.ammo)

func can_attack():
	return !cooldown and (ranged_weapon.unlimited_ammo or ranged_weapon.ammo > 0)
