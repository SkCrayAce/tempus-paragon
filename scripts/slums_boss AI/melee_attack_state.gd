class_name MeleeAttackState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

#Will move towards a random position at the leftmost grid, will damage adjacent player

signal m_attack_finished

func _enter_state():
	pass

func _exit_state():
	m_attack_finished.emit()

