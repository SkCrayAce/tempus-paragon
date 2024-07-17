class_name StunnedState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar

#If hit by player at during winding up, stun will happen
#Stun will last for 2-4 seconds

signal stun_done

func _enter_state():
	anim.play("stunned")
	await get_tree().create_timer(randi_range(2, 4)).timeout
	stun_done.emit()
	anim.stop()

func _exit_state():
	pass
