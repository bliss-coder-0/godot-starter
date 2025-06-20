extends Node2D

@export var menu_stack: MenuStack
@export var audio_click: AudioStreamPlayer
@export var play_button: Button
@export var current_track_label: Label

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if GameManager.is_paused():
			menu_stack.pop_all()
			GameManager.unpause()
		else:
			_pause()

func _pause():
	current_track_label.text = SoundtrackPlayer.get_current_track_name()
	menu_stack.push("PauseMenu")
	GameManager.pause()

func _on_button_audio_pressed() -> void:
	audio_click.play()
	menu_stack.push("AudioMenu")

func _on_button_back_pressed() -> void:
	audio_click.play()
	menu_stack.pop()
	if menu_stack.menu_stack.size() == 0:
		GameManager.unpause()

func _on_button_next_pressed() -> void:
	SoundtrackPlayer.play_next()
	current_track_label.text = SoundtrackPlayer.get_current_track_name()

func _on_button_prev_pressed() -> void:
	SoundtrackPlayer.play_previous()
	current_track_label.text = SoundtrackPlayer.get_current_track_name()

func _on_button_toggle_pressed() -> void:
	SoundtrackPlayer.toggle()
	if SoundtrackPlayer.is_playing:
		play_button.text = "||"
	else:
		play_button.text = ">"

func _on_pause_texture_button_pressed() -> void:
	_pause()
