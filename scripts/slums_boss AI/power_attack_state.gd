class_name PowerAttackState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar

#Will move towards a random position, wind up, then damage all players
#if hit during wind up, will go to stun state

signal p_attack_finished
signal hit_at_wind_up

func _enter_state():
	#go to random position in grid
	#wind up
	prints("power attacking")
	anim.play("wind_up_power")
	await anim.animation_finished
	#shake camera?
	anim.play("attack_power")
	await anim.animation_finished
	p_attack_finished.emit()

func _exit_state():
	anim.stop()
