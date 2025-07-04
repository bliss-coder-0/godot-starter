class_name BTMoveToTarget extends BTNode

@export var target_var := &"target"

@export var speed_var = 60
@export var tolerance = 20

func process(_delta: float) -> Status:
	var target = blackboard.get_var(target_var)
	if not target:
		var target_pos = target.global_position
		if abs(agent.global_position.x - target_pos.x) < tolerance:
			# agent.move(dir.x, 0)
			return Status.SUCCESS
		else:
			# agent.move(dir.x, speed_var)
			return Status.RUNNING
		
	return Status.FAILURE
