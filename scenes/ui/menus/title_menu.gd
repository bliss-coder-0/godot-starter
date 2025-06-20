extends Node2D

@export var menu_stack : MenuStack
@export var audio_click: AudioStreamPlayer

func _on_button_play_pressed() -> void:
	audio_click.play()
	SceneManager.goto_scene("res://scenes/rooms/room_1.tscn")

func _on_button_settings_pressed() -> void:
	audio_click.play()
	menu_stack.push("SettingsMenu")

func _on_button_audio_pressed() -> void:
	audio_click.play()
	menu_stack.push("AudioMenu")

func _on_button_back_pressed() -> void:
	audio_click.play()
	menu_stack.pop()

func _on_button_quit_pressed() -> void:
	audio_click.play()
	GameManager.quit()
