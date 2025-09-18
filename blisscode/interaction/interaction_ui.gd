class_name InteractionUI extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var container_node: Node2D = $ContainerNode
@onready var label: Label = $ContainerNode/Label

var is_showing: bool = false

func show_ui(message):
	label.text = message
	animation_player.play("show")
	await animation_player.animation_finished
	is_showing = true
	
func hide_ui():
	animation_player.play("hide")
	await animation_player.animation_finished
	is_showing = false
