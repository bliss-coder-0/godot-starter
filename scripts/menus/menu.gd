class_name Menu extends CanvasLayer

@export var animation_transition_in: String = "transition_in"
@export var animation_transition_out: String = "transition_out"
@export var animation_transition_away_in: String = "transition_away_in"
@export var animation_transition_away_out: String = "transition_away_out"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	_off()

func _off():
	hide()
	set_process(false)

func _on():
	show()
	set_process(true)

func transition_in():
	_on()
	animation_player.play(animation_transition_in)
	await animation_player.animation_finished

func transition_out():
	animation_player.play(animation_transition_out)
	await animation_player.animation_finished
	_off()

func transition_away_in():
	_on()
	animation_player.play(animation_transition_away_in)
	await animation_player.animation_finished
	
func transition_away_out():
	animation_player.play(animation_transition_away_out)
	await animation_player.animation_finished
	_off()
