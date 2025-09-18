class_name HotspotMouse extends Hotspot

var is_mouse_over = false

signal mouseover
signal mouseout

func _ready():
	super ()
	if interact_area:
		interact_area.input_event.connect(_on_input_event)
		interact_area.mouse_entered.connect(_on_mouse_entered)
		interact_area.mouse_exited.connect(_on_mouse_exited)

func _on_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("take"):
		var body = get_tree().get_first_node_in_group(body_group)
		if body:
			_interact_handler(body, get_global_mouse_position())
		else:
			print("No body found in group: ", body_group)

func _on_mouse_entered():
	if not in_range:
		return
	is_mouse_over = true
	mouseover.emit()
	interaction_ui.show_ui("Click To interact")

func _on_mouse_exited():
	is_mouse_over = false
	mouseout.emit()
	if interaction_ui.is_showing:
		interaction_ui.hide_ui()
