class_name RangedWeaponBase extends Node2D

@export var item_id: String

var fire_rate = 0
var fire_rate_time_elapsed: float = 0.0
var cooldown = false
var ammo = 10
var max_ammo = 10
var unlimited_ammo = false
var projectile

signal ammo_changed(ammo: int)

func _ready():
	var item = ItemCatalog.get_item(item_id)
	if item == null:
		print("Item not found for weapon")
		return
	if not item is ItemCatalog.RangedWeapon:
		print("Item is not ranged weapon")
		return
	max_ammo = item.max_ammo
	unlimited_ammo = item.unlimited_ammo
	fire_rate = item.fire_rate
	projectile = load(item.projectile)

func _process(delta: float) -> void:
	fire_rate_time_elapsed += delta
	if fire_rate_time_elapsed <= fire_rate:
		cooldown = true
	else:
		cooldown = false

func attack(direction: Vector2):
	if not can_attack():
		return
	if not unlimited_ammo:
		ammo -= 1
	fire_rate_time_elapsed = 0
	var b = projectile.instantiate()
	b.start(global_position, direction)
	get_tree().get_root().add_child(b)
	ammo_changed.emit(ammo)

func add_ammo(amount: int):
	ammo += amount
	if ammo >= max_ammo:
		ammo = max_ammo
	ammo_changed.emit(ammo)

func can_attack():
	return !cooldown and (unlimited_ammo or ammo > 0)
