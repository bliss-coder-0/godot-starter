@tool
extends Node

@export var user_config: UserConfig
@export var game_config: GameConfig

@export_tool_button("Open User Folder", "Callable") var open_user_folder_action = open_user_folder
@export_tool_button("Remove User Data", "Callable") var remove_user_data_action = remove_user_data

signal paused_toggled(is_paused: bool)

func open_user_folder():
	var user_data_path = ProjectSettings.globalize_path("user://")
	OS.shell_open(user_data_path)

func remove_user_data():
	reset()

func _ready():
	if Engine.is_editor_hint():
		return
	# Connect signals
	SignalBus.audio_volume_changed.connect(_on_audio_volume_changed)
	SignalBus.world_changed.connect(_on_world_changed)
	
	# Audio
	set_audio_volumes()
	
	# Cursor
	set_custom_cursor()

	print("GameManager ready")

func set_custom_cursor():
	if user_config.custom_cursor_texture:
		Input.set_custom_mouse_cursor(user_config.custom_cursor_texture, Input.CURSOR_ARROW, Vector2(16, 16))

func set_audio_volumes():
	AudioUtils.set_volume(0, user_config.master_volume)
	AudioUtils.set_volume(1, user_config.music_volume)
	AudioUtils.set_volume(2, user_config.ambience_volume)
	AudioUtils.set_volume(3, user_config.effects_volume)

func _on_audio_volume_changed(bus_idx: int, volume: float):
	user_config.set_volume(bus_idx, volume)
	AudioUtils.set_volume(bus_idx, volume)
	user_config.save_to_file()

func _on_world_changed(to_room_id: String, from_room_id: String, _scene_path: String, _scene_transition_name: String):
	game_config.from_world_door_id = from_room_id
	game_config.to_world_door_id = to_room_id
	
func game_start():
	GameUi.game_menus.menu_stack.pop_all()
	SceneManager.goto_scene(GameManager.game_config.game_start_scene)

func game_restore():
	GameManager.game_config.set_state(GameConfig.GAME_STATE.GAME_RESTORE)
	GameUi.game_menus.menu_stack.pop_all()
	SceneManager.goto_scene(GameManager.game_config.game_restore_scene)

func reset():
	user_config.reset()
	game_config.reset()
	UserDataStore.reset()
	print("User data reset")

func print_config():
	print("UserConfig: ", user_config.save())
	print("GameConfig: ", game_config.save())

func get_user_config() -> UserConfig:
	return user_config

func get_game_config() -> GameConfig:
	return game_config

func pause():
	get_tree().paused = true
	paused_toggled.emit(true)

func toggle_pause():
	get_tree().paused = not get_tree().paused
	paused_toggled.emit(get_tree().paused)

func unpause():
	get_tree().paused = false
	paused_toggled.emit(get_tree().paused)
