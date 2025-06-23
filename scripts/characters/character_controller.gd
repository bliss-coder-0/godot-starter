class_name CharacterController extends CharacterBody2D

@onready var state_machine: StateMachine = $StateMachine

@export var character_sheet: CharacterSheet
@export var controls: CharacterControls

@export_group("Movement")
@export var walk_speed: float = 100.0
@export var run_speed: float = 300.0
@export var allow_y_controls: bool = false
@export var movement_percent: float = 1.0

@export_group("Navigation")
@export var navigation_agent: NavigationAgent2D

@export_group("Garbage")
@export var garbage: bool = false
@export var garbage_time: float = 0.0

var speed: float = 300.0
var was_facing_right = true
var is_facing_right = true

var paralyzed: bool = false

signal spawned(pos: Vector2)
signal died(pos: Vector2)

func _ready() -> void:
	hide()

	if navigation_agent:
		navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func _on_velocity_computed(safe_velocity: Vector2):
	if Engine.is_editor_hint():
		return
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
	character_sheet.reset()
	show()
	spawned.emit(global_position)

func die():
	paralyzed = true
	if garbage:
		await get_tree().create_timer(garbage_time).timeout
		call_deferred("queue_free")
	else:
		await get_tree().create_timer(garbage_time).timeout
		hide()
	died.emit(global_position)

func take_damage(amount: int):
	character_sheet.take_damage(amount)
	if character_sheet.hp <= 0:
		die()

func save():
	var data = {
		"filename": get_scene_file_path(),
		"path": get_path(),
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"was_facing_right": was_facing_right,
		"is_facing_right": is_facing_right,
		"character_sheet": character_sheet.save()
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
	if data.has("character_sheet"):
		character_sheet.restore(data.get("character_sheet"))
