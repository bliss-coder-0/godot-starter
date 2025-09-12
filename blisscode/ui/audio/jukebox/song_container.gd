class_name SongContainer extends HBoxContainer

@export var play_button: TextureButton
@export var pause_button: TextureButton
@export var track_name: Label

signal play_button_pressed
signal pause_button_pressed

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)

	pause_button.hide()

func _on_play_button_pressed() -> void:
	play_button_pressed.emit()
	pause_button.show()
	play_button.hide()

func _on_pause_button_pressed() -> void:
	pause_button_pressed.emit()
	pause_button.hide()
	play_button.show()
