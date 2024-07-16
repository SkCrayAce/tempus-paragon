class_name MovingState
extends State

@export var actor: Boss
@export var anim: AnimatedSprite2D

#Will move to random positions in the grid, will move 1-3 times to different random positions
#will go to avoid state if took a certain amount of damage

signal moving_finished
signal take_many_damage

var top_left_tile = battle_node.top_left_tile
	

func _enter_state():
	anim.play("moving")

func _exit_state():
	anim.stop()
	moving_finished.emit()
