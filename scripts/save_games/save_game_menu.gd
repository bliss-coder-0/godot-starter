extends Node

@export var line_edit: LineEdit
@export var save_button: Button
@export var save_game_button_container: VBoxContainer
@export var animation_player: AnimationPlayer
@export var cancel_button_save: Button
@export var cancel_button_restore: Button

func _ready():
	_update_ui()

func _input(event):
	if SaveGameManager.save_game_mode == SaveGameManager.SaveGameMode.NONE:
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if event.is_action_pressed("save"):
				show_save()
			elif event.is_action_pressed("restore"):
				show_restore()
	elif SaveGameManager.save_game_mode == SaveGameManager.SaveGameMode.SAVE:
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if event.is_action_pressed("back"):
				hide_save()
	elif SaveGameManager.save_game_mode == SaveGameManager.SaveGameMode.RESTORE:
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if event.is_action_pressed("back"):
				hide_restore()

func show_save():
	GameManager.pause()
	SaveGameManager.save_game_mode = SaveGameManager.SaveGameMode.SAVE
	animation_player.play("show_save")
	await animation_player.animation_finished
	line_edit.grab_focus()
	line_edit.text = ""
	
func show_restore(pause: bool = true):
	if pause:
		GameManager.pause()
	var saves = _update_ui()
	if saves.size() == 0:
		cancel_button_restore.grab_focus()
	SaveGameManager.save_game_mode = SaveGameManager.SaveGameMode.RESTORE
	animation_player.play("show_restore")

func hide_save():
	GameManager.unpause()
	SaveGameManager.save_game_mode = SaveGameManager.SaveGameMode.NONE
	animation_player.play("hide_save")
	
func hide_restore():
	GameManager.unpause()
	SaveGameManager.save_game_mode = SaveGameManager.SaveGameMode.NONE
	animation_player.play("hide_restore")

func _update_ui():
	for child in save_game_button_container.get_children():
		child.queue_free()
	#var saves = _get_save_games()
	#for s in saves:
		#_add_button_to_container(s.description)
	#return saves

func _add_button_to_container(description: String):
	var button = Button.new()
	button.text = description
	button.pressed.connect(func _connect(): _on_restore_game_pressed(description))
	save_game_button_container.add_child(button)

func _on_save_button_pressed() -> void:
	if SaveGameManager.save_game_mode == SaveGameManager.SaveGameMode.NONE:
		return
	#save(line_edit.text)
	animation_player.play("hide_save")
	SaveGameManager.save_game_mode = SaveGameManager.SaveGameMode.NONE
	line_edit.text = ""
	save_button.disabled = true
	GameManager.unpause()
	await get_tree().create_timer(0.5).timeout
	#TextParser.send_message("Game saved", 1.0)

func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		save_button.disabled = true
	else:
		save_button.disabled = false

func _on_line_edit_text_submitted(_new_text: String) -> void:
	if SaveGameManager.save_game_mode == SaveGameManager.SaveGameMode.NONE:
		return
	_on_save_button_pressed()
	
func _on_cancel_button_pressed() -> void:
	if SaveGameManager.save_game_mode == SaveGameManager.SaveGameMode.NONE:
		return
	animation_player.play("hide_save")
	SaveGameManager.save_game_mode = SaveGameManager.SaveGameMode.NONE
	GameManager.unpause()
	
func _on_cancel_button_2_pressed() -> void:
	if SaveGameManager.save_game_mode == SaveGameManager.SaveGameMode.NONE:
		return
	animation_player.play("hide_restore")
	SaveGameManager.save_game_mode = SaveGameManager.SaveGameMode.NONE
	GameManager.unpause()

func _on_restore_game_pressed(description):
	if SaveGameManager.save_game_mode == SaveGameManager.SaveGameMode.NONE:
		return
	#var index = _find_save_game_index(description)
	#loaded_restore_index = index
	#restore(index)
