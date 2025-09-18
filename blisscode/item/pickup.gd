class_name Pickup extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var item: Item
@export var animation_name: String = "idle"
@export var start_animation: bool = false
@export var garbage_time: float = 1.0
@export var follow_target: bool = false
@export var follow_speed: float = 100.0

signal pickedup(item: Item, pos: Vector2)

var hotspots: Array[Hotspot] = []

func _ready():
	_connect_hotspots()
	if item:
		set_item(item)
	if start_animation and animation_player and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)

func _connect_hotspots():
	#  find all hotspot in the children
	for child in get_children():
		if child is Hotspot:
			hotspots.append(child)
			child.interacted.connect(_on_interacted)

func set_item(new_item: Item):
	item = new_item
	sprite.texture = item.texture
	sprite.hframes = item.hframes
	sprite.vframes = item.vframes
	sprite.frame = item.frame
	#sprite.material.set_shader_parameter("rarity", item.rarity)
	
func _on_interacted(body: CharacterController, pos: Vector2):
	_pickup_handler(body, pos)

func _get_current_body():
	for hotspot in hotspots:
		if hotspot.current_body:
			return hotspot.current_body
	return null

func _process(delta):
	var current_body = _get_current_body()
	if current_body:
		if follow_target:
			var target_pos = current_body.get_global_position()
			var current_pos = get_global_position()
			var direction = (target_pos - current_pos).normalized()
			var new_pos = current_pos + direction * follow_speed * delta
			set_global_position(new_pos)

func _pickup_handler(body, pos: Vector2):
	if body is CharacterController:
		body.item_pickup(item, pos)
	pickedup.emit(item, pos)
	hide()
	await get_tree().create_timer(garbage_time).timeout
	call_deferred("queue_free")
