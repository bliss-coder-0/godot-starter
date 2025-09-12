class_name Cutscene extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start():
	animation_player.play("transition_in")

func stop():
	animation_player.play("transition_out")
