class_name RangedAttackState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar

#Will move to random position in the grid then perform attack that will damage adjacent character

signal r_attack_finished

func _enter_state():
	#attack character
	prints("ranged attacking")
	anim.play("wind_up_ranged")
	await anim.animation_finished
	
	anim.play("attack_ranged")
	await anim.animation_finished
	r_attack_finished.emit()

func _exit_state():
	anim.stop()
