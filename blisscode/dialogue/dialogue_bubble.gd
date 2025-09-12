class_name DialogueBubble extends Node2D

@export var dialogue_text: Label
@export var animation_player: AnimationPlayer
@export var typewriter_style: bool = true

signal dialogue_shown
signal dialogue_hidden

func _ready() -> void:
	dialogue_text.hide()

func _input(_event: InputEvent) -> void:
	if dialogue_text.visible and Input.is_anything_pressed():
		dialogue_text.hide()
		dialogue_hidden.emit()

func show_dialogue(text: String):
	if not dialogue_text.visible:
		dialogue_text.show()
	dialogue_shown.emit()
	dialogue_text.text = text
	if typewriter_style:
		animation_player.play("show_dialogue")
	else:
		dialogue_text.visible_ratio = 1.0
		
