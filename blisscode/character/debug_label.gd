extends Label

@export var controls : CharacterControls

var parent

var parent_position = Vector2.ZERO
var current_gold = 0

func _ready() -> void:
	parent = get_parent()
	if parent.inventory:
		parent.inventory.gold_changed.connect(_on_gold_changed)
		current_gold = parent.inventory.gold

func _process(_delta: float) -> void:
	_update_label()

func _update_label():
	var movement_direction = controls.get_movement_direction()
	var aim_direction = controls.get_aim_direction()
	parent_position = parent.global_position.round()
	text = "%s\n%s\n%s\n%s" % [parent_position, movement_direction, aim_direction, current_gold]
	
func _on_gold_changed(amount):
	current_gold = amount
