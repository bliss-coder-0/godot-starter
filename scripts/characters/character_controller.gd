class_name CharacterController extends CharacterBody2D

@onready var state_machine: StateMachine = $StateMachine
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var character_sheet: CharacterSheet
@export var inventory: Inventory
@export var equipment: Equipment
@export var controls: CharacterControls

@export var auto_spawn: bool = false

@export_group("Movement")
@export var speed: float = 100.0
@export var walk_speed: float = 100.0
@export var run_speed: float = 300.0
@export var allow_y_controls: bool = false
@export var movement_percent: float = 1.0

@export_group("Navigation")
@export var navigation_agent: NavigationAgent2D

@export_group("Garbage")
@export var garbage: bool = false
@export var garbage_time: float = 0.0

var was_facing_right = true
var is_facing_right = true

var paralyzed: bool = false

signal spawned(pos: Vector2)
signal died(character: CharacterController)

func _ready() -> void:
	hide()
	if navigation_agent:
		navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	if auto_spawn:
		spawn(position)

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
		
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

func spawn(spawn_position: Vector2 = Vector2.ZERO):
	position = spawn_position
	velocity = Vector2.ZERO
	paralyzed = false
	show()
	spawned.emit(global_position)

func die():
	died.emit(self)
	paralyzed = true
	if garbage:
		await get_tree().create_timer(garbage_time).timeout
		call_deferred("queue_free")
	else:
		await get_tree().create_timer(garbage_time).timeout
		hide()
	
func move_to(direction: Vector2, _delta: float):
	velocity = direction * speed
	if move_and_slide():
		return true
	return false

func take_damage(amount: int):
	character_sheet.take_damage(amount)
	if character_sheet.health <= 0:
		die()

func item_pickup(item_id: String, pos: Vector2):
	var item = ItemCatalog.get_item(item_id)
	if item is ItemCatalog.Currency:
		inventory.add_gold(item.amount)
	elif item is ItemCatalog.Equipable:
		equip(item, pos)
	elif item is ItemCatalog.Consumable:
		consume(item, pos)

func consume(item, pos):
	if item.consume_on_pickup:
		if item.health > 0:
			character_sheet.add_health(item.health)
		if item.mana > 0:
			character_sheet.add_mana(item.mana)
		if item.stamina > 0:
			character_sheet.add_stamina(item.stamina)
	else:
		inventory.add(item.id, pos)

func equip(item, pos):
	if item.equip_on_pickup:
		equipment.equip(item, equipment.get_next_available_slot(item.slot))
	else:
		inventory.add(item.id, pos)

func save():
	var data = {
		"filename": get_scene_file_path(),
		"path": get_path(),
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"rotation": rotation,
		"velocity_x": velocity.x,
		"velocity_y": velocity.y,
		"was_facing_right": was_facing_right,
		"is_facing_right": is_facing_right,
		#"character_sheet": character_sheet.save(),
		#"inventory": inventory.save()
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
	if data.has("rotation"):
		rotation = data.get("rotation")
	if data.has("velocity_x"):
		velocity.x = data.get("velocity_x")
	if data.has("velocity_y"):
		velocity.y = data.get("velocity_y")
	#if data.has("character_sheet"):
		#character_sheet.restore(data.get("character_sheet"))
	#if data.has("inventory"):
		#inventory.restore(data.get("inventory"))
