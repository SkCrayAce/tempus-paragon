class_name StunnedState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

#If hit by player at during winding up, stun will happen
#Stun will last for 2-4 seconds

signal stun_done

func _enter_state():
	pass

func _exit_state():
	stun_done.emit()
