class_name MovingState
extends State

@export var actor: Boss
@export var anim: AnimatedSprite2D

#Will move to random positions in the grid, will move 1-3 times to different random positions

signal moving_finished

func _enter_state():
	anim.play("moving")

func _exit_state():
	anim.stop()
	moving_finished.emit()
