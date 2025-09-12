class_name MenuBackButton extends Button

@export var menu_stack: MenuStack
@export var unpause_game : bool = false

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	menu_stack.pop()
	if unpause_game:
		get_tree().paused = false
