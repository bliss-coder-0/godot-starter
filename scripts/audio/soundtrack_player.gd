extends Node2D

@export var playlists: Dictionary = {}
@export var current_playlist: String = "Peace"
@export var fade_duration: float = 5.0

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var is_playing: bool = false
var is_repeating: bool = true
var current_track_index: int = 0
var current_track_name: String = ""
var preloaded_tracks: Dictionary = {}
var fade_tween: Tween

func _ready():
	audio_stream_player.finished.connect(_on_finished)
	preload_all_tracks()
	if playlists.has(current_playlist):
		start(current_playlist)
	else:
		print("Playlist not found: ", current_playlist)

func preload_all_tracks():
	for playlist_name in playlists:
		preloaded_tracks[playlist_name] = []
		var tracks: Array = playlists[playlist_name]
		for track_path in tracks:
			var loaded_track = load(track_path)
			if loaded_track:
				preloaded_tracks[playlist_name].append(loaded_track)
			else:
				print("Failed to load track: ", track_path)

func start(playlist: String, repeat: bool = true):
	if current_playlist != playlist or !audio_stream_player.playing:
		is_repeating = false
		audio_stream_player.stop()
		is_repeating = repeat
		current_playlist = playlist
		current_track_index = randi() % playlists[current_playlist].size()
		start_playlist()

func get_current_track_name() -> String:
	var current_track: String = playlists[current_playlist][current_track_index]
	return current_track.split("/")[-1].split(".")[0]

func start_playlist():
	var tracks: Array = preloaded_tracks[current_playlist]
	if tracks != []:
		audio_stream_player.stream = tracks[current_track_index]
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
	var tracks: Array = playlists[current_playlist]
	if tracks != []:
		current_track_index = (current_track_index + 1) % tracks.size()
		audio_stream_player.stop()
		is_playing = false
		start_playlist()

func play_previous():
	var tracks: Array = playlists[current_playlist]
	if tracks != []:
		current_track_index = (current_track_index - 1) % tracks.size()
		audio_stream_player.stop()
		is_playing = false
		start_playlist()

func play():
	if !is_playing:
		is_playing = true
		audio_stream_player.volume_db = -80.0 # Start silent for fade in
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
		
func _on_button_next_pressed() -> void:
	play_next()
	#current_track_label.text = get_current_track_name()

func _on_button_prev_pressed() -> void:
	play_previous()
	#current_track_label.text = get_current_track_name()

func _on_button_toggle_pressed() -> void:
	toggle()
	#if is_playing:
		#play_button.text = "||"
	#else:
		#play_button.text = ">"
