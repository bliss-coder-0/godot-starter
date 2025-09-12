@tool
class_name RangedWeapon extends Weapon

@export var projectile: String = ""
@export var max_ammo: int = 0
@export var unlimited_ammo: bool = false
@export var ammo: int = 0

func save():
	var data = super.save()
	data["projectile"] = projectile
	data["max_ammo"] = max_ammo
	data["unlimited_ammo"] = unlimited_ammo
	data["ammo"] = ammo
	return data

func restore(data):
	super.restore(data)
	if data.has("projectile"):
		projectile = data["projectile"]
	if data.has("max_ammo"):
		max_ammo = data["max_ammo"]
	if data.has("unlimited_ammo"):
		unlimited_ammo = data["unlimited_ammo"]
	if data.has("ammo"):
		ammo = data["ammo"]
