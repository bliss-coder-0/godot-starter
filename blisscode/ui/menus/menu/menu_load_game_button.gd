class_name MenuLoadGameButton extends Button

@export var save_index: int = -1

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if save_index >= 0:
		UserDataStore.user_data_store_config.save_index = save_index
		GameManager.game_restore()
	else:
		print("Invalid save index: ", save_index)
