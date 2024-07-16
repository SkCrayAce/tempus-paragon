class_name PowerAttackState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

#Will move towards a random position, wind up, then damage all players
#if hit during wind up, will go to stun state

signal p_attack_finished

func _enter_state():
	pass

func _exit_state():
	p_attack_finished.emit()
