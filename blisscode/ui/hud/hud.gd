class_name HUD extends Node2D

@export var seconds_label: Label
@export var enemies_label: Label
@export var animation_player: AnimationPlayer

#func _ready() -> void:
	#room_filler.enemies_killed.connect(_on_enemies_killed)

#func _on_enemies_killed(count: int, max_count: int) -> void:
	#enemies_label.text = "%d/%d" % [count, max_count]

func _process(_delta: float) -> void:
	if seconds_label:
		seconds_label.text = "%.2f" % (Time.get_ticks_msec() / 1000.0)
		
func show_hud():
	animation_player.play("transition_in")
	
func hide_hud():
	animation_player.play("transition_out")
