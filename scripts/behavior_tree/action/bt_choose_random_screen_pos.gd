class_name BTChooseRandomScreenPos extends BTNode

@export var position_var: StringName = &"pos"

func process(_delta: float) -> Status:
	var viewport_size = agent.get_viewport().get_visible_rect().size
	var pos = Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	)
	blackboard.set_var(position_var, pos)
	return Status.SUCCESS
