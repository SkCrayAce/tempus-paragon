class_name FiniteStateMachine
extends Node

@export var state: State


func _ready():
	if global.boss_is_defeated:
		return
	change_state(state)

	
func change_state(new_state: State):
	if not global.boss_is_defeated:
		if state is State:
			state._exit_state()
		new_state._enter_state()
		state = new_state


