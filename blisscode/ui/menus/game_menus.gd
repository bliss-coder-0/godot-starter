class_name GameMenus extends Node2D

@export var menu_stack: MenuStack
@export var audio_click: AudioStreamPlayer
@export var show_menu_on_start: String = ""

func _ready() -> void:
	if show_menu_on_start != "":
		menu_stack.push(show_menu_on_start)
