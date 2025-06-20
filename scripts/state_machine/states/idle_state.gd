class_name IdleState extends State

func process_physics(_delta: float) -> void:
	if parent.is_movement_pressed():
		parent.state_machine.dispatch("move")
