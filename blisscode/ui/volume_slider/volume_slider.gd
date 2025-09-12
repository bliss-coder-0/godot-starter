extends Control

@export var bus_idx: int = 0
@export var label_text: String = ""

@onready var label: Label = $VBoxContainer/Label
@onready var slider: Slider = $VBoxContainer/HSlider

func _ready():
	label.text = label_text
	var percent = GameManager.user_config.get_volume(bus_idx)
	slider.set_value_no_signal(percent)

func _on_h_slider_value_changed(value: float):
	SignalBus.audio_volume_changed.emit(bus_idx, value)
