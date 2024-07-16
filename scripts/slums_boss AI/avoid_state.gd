class_name AvoidState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

#After finishing stunned state, it will enter to this state
#or after recieving a certain amount of damage
#Boss gets out of grid and summons a wave of virulents

signal summon_finished

func _enter_state():
	pass

func _exit_state():
	pass
