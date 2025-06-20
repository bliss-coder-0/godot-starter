class_name SceneTransition extends CanvasLayer

@export var animation_transition_in: String = "transition_in"
@export var animation_transition_out: String = "transition_out"
@export var animation_blink: String = "blink"
@export var play_on_start: bool = false
@export var goto_scene: String = ""
@export var audio_click: AudioStreamPlayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var bypass_blink: bool = false

func _ready():
	if play_on_start:
		play()

func _unhandled_input(_event: InputEvent) -> void:
	if bypass_blink == false and goto_scene != "":
		if Input.is_anything_pressed():
			audio_click.play()
			bypass_blink = true
			animation_player.stop()
			await transition_out()
			SceneManager.goto_scene(goto_scene)

func play():
	await transition_in()
	if animation_blink != "":
		if not bypass_blink:
			await blink()
	else:
		await transition_out()

func transition_in():
	animation_player.play(animation_transition_in)
	await animation_player.animation_finished

func blink():
	animation_player.play(animation_blink)
	await animation_player.animation_finished

func transition_out():
	animation_player.play(animation_transition_out)
	await animation_player.animation_finished
