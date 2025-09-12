class_name Jukebox extends Node2D

@export var current_playlist: String = "Peace"
@export var play_on_start: bool = false
@export var fade_duration: float = 5.0
@export var data_store_dir: String = "playlists"

@export_group("UI")
@export var playlist_name_label: Label
@export var previous_button: TextureButton
@export var play_button: TextureButton
@export var stop_button: TextureButton
@export var pause_button: TextureButton
@export var repeat_button: TextureButton
@export var next_button: TextureButton
@export var songlist_container: VBoxContainer
@export var song_container_scene: PackedScene


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var playlists: Dictionary = {}
var is_playing: bool = false
var is_repeating: bool = true
var current_track_index: int = 0
var current_track_name: String = ""
var preloaded_tracks: Dictionary = {}
var fade_tween: Tween

func _ready():
	audio_stream_player.finished.connect(_on_finished)
	previous_button.pressed.connect(_on_previous_button_pressed)
	play_button.pressed.connect(_on_play_button_pressed)
	stop_button.pressed.connect(_on_stop_button_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	repeat_button.pressed.connect(_on_repeat_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)

	stop_button.hide()
	pause_button.hide()

	preload_all_tracks()
	set_playlist(current_playlist)
	if play_on_start and playlists.has(current_playlist):
		start(current_playlist)

func preload_all_tracks():
	playlists = DataStore.get_store_directory(data_store_dir)
	for playlist_name in playlists:
		preloaded_tracks[playlist_name] = []
		if playlists[playlist_name].has("tracks") and playlists[playlist_name].has("path"):
			var tracks: Array = playlists[playlist_name].tracks
			var base_path: String = playlists[playlist_name].path
			for track_filename in tracks:
				var full_track_path = base_path + track_filename
				var loaded_track = load(full_track_path)
				if loaded_track:
					var track_name = track_filename.split(".")[0]
					var track_object = {
						"name": track_name,
						"track": loaded_track
					}
					preloaded_tracks[playlist_name].append(track_object)
				else:
					print("Failed to load track: ", full_track_path)

func start(playlist: String, repeat: bool = true):
	if current_playlist != playlist or !audio_stream_player.playing:
		is_repeating = false
		audio_stream_player.stop()
		is_repeating = repeat
		current_playlist = playlist
		if preloaded_tracks.has(playlist) and preloaded_tracks[playlist].size() > 0:
			current_track_index = randi() % preloaded_tracks[playlist].size()
		else:
			current_track_index = 0
		start_playlist()

func get_current_track_name() -> String:
	var track_objects: Array = preloaded_tracks[current_playlist]
	if track_objects.size() > current_track_index:
		return track_objects[current_track_index].name
	return ""

func get_playlist_track_names() -> Array:
	var track_objects: Array = preloaded_tracks[current_playlist]
	if track_objects != []:
		return track_objects.map(func(track_object): return track_object.name)
	return []

func set_playlist(playlist: String):
	current_playlist = playlist
	build_playlist(current_playlist, get_playlist_track_names())

func start_playlist():
	var track_objects: Array = preloaded_tracks[current_playlist]
	if track_objects != []:
		audio_stream_player.stream = track_objects[current_track_index].track
		audio_stream_player.volume_db = -80.0 # Start silent for fade in
		audio_stream_player.play()
		is_playing = true
		fade_in()

func fade_in():
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(audio_stream_player, "volume_db", -10.0, fade_duration)

func fade_out():
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(audio_stream_player, "volume_db", -80.0, fade_duration)
	fade_tween.tween_callback(audio_stream_player.stop)

func play_next():
	var track_objects: Array = preloaded_tracks[current_playlist]
	if track_objects != []:
		current_track_index = (current_track_index + 1) % track_objects.size()
		audio_stream_player.stop()
		is_playing = false
		start_playlist()

func play_previous():
	var track_objects: Array = preloaded_tracks[current_playlist]
	if track_objects != []:
		current_track_index = (current_track_index - 1) % track_objects.size()
		audio_stream_player.stop()
		is_playing = false
		start_playlist()

func play():
	if !is_playing:
		is_playing = true
		audio_stream_player.volume_db = -80.0
		audio_stream_player.play()
		fade_in()

func stop():
	if is_playing:
		is_playing = false
		fade_out()

func toggle():
	if is_playing:
		stop()
	else:
		play()

func _on_finished():
	if is_repeating:
		play_next()
		
func _on_previous_button_pressed() -> void:
	play_previous()

func _on_play_button_pressed() -> void:
	start_playlist()
	pause_button.show()
	play_button.hide()

func _on_stop_button_pressed() -> void:
	stop()
	pause_button.hide()
	play_button.show()

func _on_pause_button_pressed() -> void:
	stop()
	pause_button.show()
	play_button.hide()

func _on_repeat_button_pressed() -> void:
	# repeat()
	pass

func _on_next_button_pressed() -> void:
	play_next()

func build_playlist(playlist_name: String, playlist: Array) -> void:
	playlist_name_label.text = playlist_name
	for track in playlist:
		var song_container = song_container_scene.instantiate()
		song_container.track_name.text = track.split("/")[-1].split(".")[0]
		song_container.play_button.pressed.connect(_on_play_button_pressed)
		song_container.pause_button.pressed.connect(_on_pause_button_pressed)
		songlist_container.add_child(song_container)
