extends Node2D

@export var label: Label

var parent

func _ready() -> void:
	parent = get_parent()
	parent.character_sheet.alignment_changed.connect(_on_alignment_changed)
	refresh_ui()

func _on_alignment_changed(_alignment: float) -> void:
	refresh_ui()
	
func refresh_ui():
	var heat = parent.character_sheet.get_heat()
	if (heat > 0):
		var heat_stars = parent.character_sheet.get_heat_stars()
		label.text = heat_stars
		label.show()
	else:
		label.hide()
