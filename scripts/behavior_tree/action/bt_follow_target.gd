class_name BTFollowTarget extends BTNode

@export var target_var := &"target"

func process(delta: float) -> Status:
	var target: CharacterBody2D = blackboard.get_var(target_var, null)
	if target == null:
		return Status.FAILURE
		
	var direction = (target.global_position - agent.global_position).normalized()
	if agent.move_to(direction, delta):
		return Status.SUCCESS
		
	return Status.RUNNING
