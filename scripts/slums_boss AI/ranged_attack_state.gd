class_name RangedAttackState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

#Will move to random position in the grid then perform attack that will damage adjacent character

signal r_attack_finished

func _enter_state():
	pass

func _exit_state():
	r_attack_finished.emit()
