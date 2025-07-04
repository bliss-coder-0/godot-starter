class_name BTAttack extends BTNode

@export var weapon: RangedWeaponBase
@export var target_var: StringName = &"target"
@export var lock_on: bool = true

var target

func process(_delta: float) -> Status:
	if weapon == null:
		return Status.FAILURE
	target = blackboard.get_var(target_var)
	if lock_on:
		var direction: Vector2 = target.global_position - agent.global_position
		weapon.attack(direction)
	else:
		var direction: Vector2 = Vector2.RIGHT.rotated(weapon.global_rotation)
		weapon.attack(direction)
	return Status.SUCCESS
