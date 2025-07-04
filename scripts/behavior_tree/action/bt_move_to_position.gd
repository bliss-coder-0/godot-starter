class_name BTMoveToPosition extends BTNode

@export var pos_var := &"pos"
@export var target_var := &"target"

@export var tolerance = 10

func process(delta: float) -> Status:
	var target = blackboard.get_var(target_var, null)
	if target != null:
		return Status.FAILURE

	var pos: Vector2 = blackboard.get_var(pos_var, Vector2.ZERO)
	var direction = (pos - agent.global_position).normalized()
	if agent.move_to(direction, delta):
		return Status.SUCCESS
		
	if agent.global_position.distance_to(pos) < tolerance:
		return Status.SUCCESS
		
	return Status.RUNNING
