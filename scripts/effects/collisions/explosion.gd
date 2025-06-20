class_name Explosion extends Node2D

@export var animation_player: AnimationPlayer
@export var animation_name: String = "Explode"
@export var screen_shake_amount: float = 0.0

@export_category("Audio")
@export var audio: AudioStreamPlayer2D
@export_range(-100.0, 0) var min_audio_level: float = -10
@export_range(-100.0, 0) var max_audio_level: float = -5

func _ready():
	var screen_shake = get_tree().get_first_node_in_group("screen_shake")
	if screen_shake_amount > 0.0 and screen_shake != null:
		screen_shake.apply_shake(screen_shake_amount)
	if audio != null:
		var rand_level = randf_range(min_audio_level, max_audio_level)
		audio.volume_db = rand_level
		audio.play()
	if animation_player:
		animation_player.play(animation_name)
		await animation_player.animation_finished
	call_deferred("queue_free")
