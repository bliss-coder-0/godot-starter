class_name DashState extends MoveState

@export var dash_time: float = .05

var dash_time_elapsed: float = 0

func enter() -> void:
	dash_time_elapsed = 0
	super ()
	_apply_dash()
	
func process_frame(delta: float) -> void:
	dash_time_elapsed -= delta
	if dash_time_elapsed <= 0:
		state_machine.dispatch("dash_finished")

func _apply_dash():
	dash_time_elapsed = dash_time
	var direction = parent.controls.get_movement_direction()
	parent.velocity += direction * PhysicsManager.dash_force * parent.movement_percent
