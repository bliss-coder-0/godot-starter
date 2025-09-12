extends Node2D

@export var dialogue_bubble: DialogueBubble
@export var dialogue_bubble2: DialogueBubble

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	dialogue_bubble.show_dialogue("What the fuck??")
	await get_tree().create_timer(1.0).timeout
	dialogue_bubble2.show_dialogue("Holy shit!!")
