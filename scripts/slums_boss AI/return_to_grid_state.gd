#Will return to a random valid position in grid

class_name ReturnToGridState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

signal returned_to_grid

func _enter_state():
	#go to random valid position in grid from being outside the grid
	anim.play("moving")
	#returned_to_grid.emit()

func _exit_state():
	anim.stop()
