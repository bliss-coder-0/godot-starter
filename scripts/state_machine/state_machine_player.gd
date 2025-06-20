class_name StateMachinePlayer extends Node

@export var parent_node: Node
@export var state_machine: StateMachine
@export var is_active: bool = false

func _ready():
	if not state_machine:
		push_error("StateMachinePlayer: No state machine assigned")
		return
	
	state_machine.init(parent_node)
		
	state_machine.add_transition(state_machine.states.get("IdleState"), state_machine.states.get("MoveState"), "move")
	state_machine.add_transition(state_machine.states.get("MoveState"), state_machine.states.get("IdleState"), "idle")
	state_machine.add_transition(state_machine.states.get("MoveState"), state_machine.states.get("DashState"), "dash")
	state_machine.add_transition(state_machine.states.get("DashState"), state_machine.states.get("MoveState"), "dash_finished")

func _process(delta):
	if state_machine and is_active:
		state_machine.process_frame(delta)

func _physics_process(delta):
	if state_machine and is_active:
		state_machine.process_physics(delta)

func _input(event):
	if state_machine and is_active:
		state_machine.process_input(event)
