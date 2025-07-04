class_name Pickup extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var item_id: String = "food_1"
@export var pickup_on_collision: bool = true
@export var pickup_with_input: bool = true
@export var player_group: String = "player"

@export var pickup_area: Area2D
@export var in_range_area: Area2D
@export var follow_target: bool = false
@export var follow_speed: float = 100.0
@export var animation_name: String = "idle"
@export var start_animation: bool = false
@export var audio: AudioStreamPlayer

var in_range: bool = false
var local_collision_pos: Vector2
var is_mouse_over = false
var target_in_range: CharacterController

signal pickedup(item_id: String, pos: Vector2)

func _ready():
	if item_id == "":
		item_id = ItemCatalog.generate_random_item_id(1)

	if pickup_area:
		pickup_area.body_entered.connect(_on_body_entered)
		pickup_area.input_event.connect(_on_input_event)
		pickup_area.mouse_entered.connect(_on_mouse_entered)
		pickup_area.mouse_exited.connect(_on_mouse_exited)
	if in_range_area:
		in_range_area.body_entered.connect(_on_in_range_body_entered)
		in_range_area.body_exited.connect(_on_in_range_body_exited)
	if item_id and sprite:
		_set_icon()
	if start_animation and animation_player and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
	
func _set_icon():
	var item = ItemCatalog.get_item(item_id)
	if item and item.sprite:
		sprite.texture = item.sprite.texture
		sprite.hframes = item.sprite.hframes
		sprite.vframes = item.sprite.vframes
		sprite.frame = item.sprite.frame
		sprite.material.set_shader_parameter("rarity", item.rarity)
	
func _process(delta):
	if follow_target and target_in_range:
		var target_pos = target_in_range.get_global_position()
		var current_pos = get_global_position()
		var direction = (target_pos - current_pos).normalized()
		var new_pos = current_pos + direction * follow_speed * delta
		set_global_position(new_pos)

func _on_input_event(_viewport, _event, _shape_idx):
	if pickup_with_input and Input.is_action_just_pressed("take"):
		var body = get_tree().get_first_node_in_group(player_group)
		if body:
			_pickup_handler(body, get_global_mouse_position())
		else:
			print("No player found in group: ", player_group)
	
func _pickup_handler(body, pos: Vector2):
	if not in_range:
		return
	if audio:
		audio.play()
	if body is CharacterController:
		body.item_pickup(item_id, pos)
	pickedup.emit(item_id, pos)
	hide()
	await get_tree().create_timer(1.0).timeout
	call_deferred("queue_free")
		
func _integrate_forces(state):
	if (state.get_contact_count() >= 1):
		local_collision_pos = state.get_contact_local_pos(0)

func _on_body_entered(body):
	if pickup_on_collision and body.is_in_group(player_group):
		var collision_position = local_collision_pos + get_position()
		_pickup_handler(body, collision_position)

func _on_in_range_body_entered(body):
	if body.is_in_group(player_group):
		in_range = true
		target_in_range = body

func _on_in_range_body_exited(_body):
	in_range = false
	target_in_range = null

func _on_mouse_entered():
	if not in_range:
		return
	is_mouse_over = true
	GameManager.set_cursor_hover()

func _on_mouse_exited():
	is_mouse_over = false
	GameManager.set_cursor_default()
