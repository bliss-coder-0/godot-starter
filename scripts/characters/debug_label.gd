extends Label

@export var controls : PlayerControls

var parent

var state_name
var parent_position

func _ready() -> void:
	parent = get_parent()
	await parent.ready
	parent.state_machine.state_changed.connect(_on_state_change)
	state_name = parent.state_machine.current_state.name

func _process(_delta: float) -> void:
	_update_parent_position()
	_update_label()

func _on_state_change(new_state, _prev_state):
	state_name = new_state.name
	_update_label()

func _update_label():
	var movement_direction = controls.get_movement_direction()
	var aim_direction = controls.get_aim_direction()
	text = "%s\n%s\n%s\n%s" % [state_name, parent_position, movement_direction, aim_direction]

func _update_parent_position():
	parent_position = parent.global_position.round()
