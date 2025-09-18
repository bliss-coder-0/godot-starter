class_name Hotspot extends Node2D

@export var interact_area: Area2D
@export var in_range_area: Area2D
@export var interact_audio: AudioStreamPlayer
@export var interaction_ui: InteractionUI
@export var interaction_text: String = "Press F To interact"
@export var body_group: String = "player"

var in_range: bool = false
var local_collision_pos: Vector2
var current_body: CharacterController

signal interacted(body: CharacterController, pos: Vector2)

func _ready():
	if in_range_area:
		in_range_area.body_entered.connect(_on_in_range_body_entered)
		in_range_area.body_exited.connect(_on_in_range_body_exited)

func _interact_handler(body, pos: Vector2):
	if not in_range:
		return
	if interact_audio:
		interact_audio.play()
	if interaction_ui:
		interaction_ui.hide_ui()
	interacted.emit(body, pos)
		
func _integrate_forces(state):
	if (state.get_contact_count() >= 1):
		local_collision_pos = state.get_contact_local_pos(0)

func _on_in_range_body_entered(body):
	in_range = true
	current_body = body
	if interaction_ui and interaction_text:
		interaction_ui.show_ui(interaction_text)

func _on_in_range_body_exited(_body):
	in_range = false
	current_body = null
	if interaction_ui and interaction_text:
		interaction_ui.hide_ui()
