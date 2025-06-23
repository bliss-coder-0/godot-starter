class_name MenuBackButton extends Button

@export var menu_stack: MenuStack
@export var audio_click: AudioStreamPlayer

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	audio_click.play()
	menu_stack.pop()
